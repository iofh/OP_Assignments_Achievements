-- Delete all tables if the tables exists
DROP TABLE IF EXISTS dbo.AssemblySubcomponent
GO

DROP TABLE IF EXISTS dbo.QuoteComponent
GO

DROP TABLE IF EXISTS dbo.Component
GO

DROP TABLE IF EXISTS dbo.Quote
GO

DROP TABLE IF EXISTS dbo.Category
GO

DROP TABLE IF EXISTS dbo.Supplier
GO

DROP TABLE IF EXISTS dbo.Customer
GO

DROP TABLE IF EXISTS dbo.Contact
GO




CREATE TABLE Category(
	[CategoryID] INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[CategoryName] NVARCHAR(32) NOT NULL,
	)
GO
CREATE TABLE Contact(
	[ContactID] INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[ContactName] NVARCHAR(100) NOT NULL,
	[ContactPhone] NVARCHAR(20) NOT NULL,
	[ContactMobilePhone] NVARCHAR(20) NULL,
	[ContactPostalAddress] NVARCHAR(255) NOT NULL,
	[ContactWWW] NVARCHAR(255) NULL,
	[ContactEmail] NVARCHAR(32) NULL,
	[ContactFax] NVARCHAR(20) NULL,

)
GO
CREATE TABLE Supplier(
	[SupplierID] INT NOT NULL,
	[SupplierGST] DECIMAL(2,2) DEFAULT 0.15 NOT NULL,
	CONSTRAINT [PK_SupplierID] PRIMARY KEY CLUSTERED (SupplierID),
	CONSTRAINT [FK_Supplier_Contact] FOREIGN KEY (SupplierID) REFERENCES Contact (ContactID)
	ON UPDATE CASCADE
	ON DELETE NO ACTION
)

GO
CREATE TABLE Customer(
	[CustomerID] INT NOT NULL,
	CONSTRAINT [PK_CustomerID] PRIMARY KEY CLUSTERED (CustomerID),
	CONSTRAINT [FK_Customer_Contact] FOREIGN KEY (CustomerID) REFERENCES Contact (ContactID)
	ON UPDATE CASCADE 
	ON DELETE CASCADE
)
GO
CREATE TABLE Component(
	[ComponentID] INT IDENTITY(3000,1) PRIMARY KEY NOT NULL,
	[ComponentName] NVARCHAR(100) NOT NULL,
	[ComponentDescription] NVARCHAR(1500) NOT NULL,
	[ListPrice] DECIMAL(8,4) NOT NULL CHECK (ListPrice >= 0.0) DEFAULT 0.0,
	[TradePrice] DECIMAL(8,4) NOT NULL CHECK (TradePrice >= 0.0) DEFAULT 0.0,
	[TimeToFit] DECIMAL(10,2) NOT NULL CHECK (TimeToFit >= 0.0)  DEFAULT 0.0,
	[CategoryID] INT NOT NULL,
	[SupplierID] INT NOT NULL,
	CONSTRAINT [FK_Component_Category] FOREIGN KEY (CategoryID) REFERENCES Category (CategoryID)
	ON UPDATE NO ACTION  --trigger will cause on update cascade 
	ON DELETE CASCADE,
	CONSTRAINT [FK_Component_Supplier] FOREIGN KEY (SupplierID) REFERENCES Supplier (SupplierID)
	ON UPDATE NO ACTION --trigger will cause on update cascade 
	ON DELETE NO ACTION
)

GO
CREATE TABLE Quote(
	[QuoteID] INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[QuoteDescription] NVARCHAR(1000) NOT NULL,
	[QuoteDate] DATETIME NOT NULL,
	[QuotePrice] DECIMAL(8,4) CHECK (QuotePrice >= 0.0) NULL,
	[QuoteCompiler] NVARCHAR(100) NOT NULL DEFAULT '',
	[CustomerID] INT NOT NULL,
	CONSTRAINT [FK_Quote_Customer] FOREIGN KEY (CustomerID) REFERENCES Customer (CustomerID)
	ON UPDATE CASCADE 
	ON DELETE NO ACTION
)
GO


CREATE TABLE QuoteComponent(
	[ComponentID] INT NOT NULL,
	[QuoteID] INT NOT NULL,
	[Quantity] DECIMAL(15,8) NOT NULL CHECK (Quantity >= 0.0) DEFAULT 0.0,
	[TradePrice] DECIMAL(8,4) NOT NULL CHECK (TradePrice >= 0.0) DEFAULT 0.0,
	[ListPrice] DECIMAL(8,4) NOT NULL CHECK (ListPrice >= 0.0) DEFAULT 0.0,
	[TimeToFit] DECIMAL(10,2) NOT NULL CHECK (TimeToFit >= 0.0) DEFAULT 0.0,
	CONSTRAINT [PK_ComponentID_QuoteID] PRIMARY KEY CLUSTERED (ComponentID, QuoteID),
	CONSTRAINT [FK_QuoteComponent_Quote] FOREIGN KEY (QuoteID) REFERENCES Quote (QuoteID)
	ON UPDATE CASCADE 
	ON DELETE CASCADE,
	CONSTRAINT [FK_QuoteComponent_Component] FOREIGN KEY (ComponentID) REFERENCES Component (ComponentID)
	ON UPDATE NO ACTION --trigger will cause update cascade
	ON DELETE NO ACTION
)
GO


CREATE TABLE AssemblySubcomponent(
	[AssemblyID] INT NOT NULL,
	[SubcomponentID] INT NOT NULL,
	[Quantity] DECIMAL(15,8) NOT NULL CHECK (Quantity >= 0.0) DEFAULT 0.0,
	CONSTRAINT [PK_AssemblyID_SubcomponentID] PRIMARY KEY CLUSTERED (AssemblyID, SubcomponentID),
	--CONSTRAINT [CHK_AssemblyID_ne_SubcomponentID] CHECK (AssemblyID <> SubcomponentID), --remove to prevent CyclicAssembly
	CONSTRAINT [FK_Subcomponent_Component] FOREIGN KEY (SubcomponentID) REFERENCES Component (ComponentID)
	ON UPDATE NO ACTION --trigger will cause update cascade
	ON DELETE NO ACTION,
	CONSTRAINT [FK_Assembly_Component] FOREIGN KEY (AssemblyID) REFERENCES Component (ComponentID)
	ON UPDATE NO ACTION --trigger will cause update cascade
	ON DELETE NO ACTION
)
GO



drop function dbo.getCategoryID
drop function dbo.getAssemblySupplierID
drop proc createAssembly
drop proc addSubComponent
GO



CREATE OR ALTER FUNCTION getCategoryID(@categoryName NVARCHAR(20))
RETURNS INT
AS
BEGIN
	RETURN(SELECT CategoryID FROM Category WHERE CategoryName=@categoryName)
END
GO

CREATE OR ALTER FUNCTION getAssemblySupplierID()
RETURNS INT
AS
BEGIN
	RETURN(SELECT ContactID FROM Contact WHERE ContactName='BIT Manufacturing Ltd.')
END
GO

CREATE OR ALTER PROC createAssembly(@componentName NVARCHAR(100),@componentDescription NVARCHAR(1500))
AS
BEGIN
	DECLARE @categoryID INT
	DECLARE @supplierID INT
	SET @categoryID = dbo.getCategoryID('Assembly')
	SET @supplierID = dbo.getAssemblySupplierID()
	INSERT Component(ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
	VALUES(@componentName, @componentDescription, @supplierID, 0, 0, 0, @categoryID)
END
GO



CREATE OR ALTER PROC addSubComponent(@assemblyName NVARCHAR(100), @subComponentName NVARCHAR(100), @quantity DECIMAL(15,8))
AS
BEGIN
	INSERT INTO AssemblySubcomponent
		(AssemblyID,SubcomponentID,Quantity)
	SELECT c1.ComponentID, c2.ComponentID, @quantity
            FROM Component c1 ,(select ComponentID from component where ComponentName=@subComponentName) c2
            where c1.ComponentName=@assemblyName	
END
GO

DROP PROC createCustomer
DROP PROC createQuote
DROP PROC addQuoteComponent

go
CREATE OR ALTER PROC createCustomer(@name NVARCHAR(100),
    @phone NVARCHAR(20),
    @postalAddress NVARCHAR(255),
    @email NVARCHAR(255)=NULL,
    @www NVARCHAR(255)=NULL,
    @fax NVARCHAR(20)=NULL,
    @mobilePhone NVARCHAR(20)=NULL,
    @customerID INT OUTPUT
)
AS
BEGIN
	INSERT Contact (ContactName, ContactPostalAddress, ContactWWW, ContactEmail, ContactPhone, ContactFax, ContactMobilePhone)
    VALUES(@name, @postalAddress, @www, @email, @phone, @fax, @mobilePhone);

    SET @customerID = (SELECT @@IDENTITY);
    INSERT INTO Customer
        (CustomerID)
    VALUES
        (@customerID)
END
RETURN @customerID
GO


CREATE OR ALTER PROC createQuote(
	@QuoteDescription NVARCHAR(1000), 
	@QuoteDate DATETIME=NULL, 
	@QuoteCompiler NVARCHAR(100)=NULL, 
	@CustomerID INT, 
	@QuoteID INT OUTPUT
)
AS
BEGIN
	DECLARE @quotePrice DECIMAL(8,4)
	SET @quotePrice = NULL
	IF @quoteCompiler IS NULL SET @quoteCompiler=''
	IF @quoteDate IS NULL SET @quoteDate = getdate()
    INSERT Quote(QuoteDescription, QuoteDate, QuotePrice, QuoteCompiler, CustomerID)
	values(@QuoteDescription, @QuoteDate, @quotePrice, @QuoteCompiler, @CustomerID)
	SET @QuoteID = (SELECT @@IDENTITY)
END
RETURN @QuoteID
GO

CREATE OR ALTER PROC addQuoteComponent(@quoteID INT, @componentID INT, @quantity DECIMAL(15,8))
AS
BEGIN
    DECLARE @tradePrice DECIMAL(8,4)
    DECLARE @listPrice DECIMAL(8,4)
    DECLARE @timeToFit DECIMAL(10,2)
    SET @tradePrice = (SELECT TradePrice FROM Component WHERE ComponentID=@componentID)
    SET @listPrice = (SELECT ListPrice FROM Component WHERE ComponentID=@componentID)
    SET @timeToFit = (SELECT TimeToFit FROM Component WHERE ComponentID=@componentID)
    INSERT QuoteComponent (ComponentID, QuoteID, Quantity, TradePrice, ListPrice, TimeToFit)
    VALUES (@componentID, @quoteID, @quantity, @tradePrice, @listPrice, @timeToFit)
END
GO

--Cascade update for category to component
CREATE OR ALTER TRIGGER trig_cas_update_Category ON Category
INSTEAD OF UPDATE
AS
BEGIN
	if UPDATE(CategoryID)
		DECLARE @cid INT=(SELECT CategoryID FROM inserted)
		DECLARE @dcid INT=(SELECT CategoryID FROM deleted)
		DECLARE @cName NVARCHAR(32)=(select CategoryName from Category where CategoryID = @dcid)
		SET IDENTITY_INSERT Category ON
			insert Category(CategoryID,CategoryName) values (@cid,@cName)

			ALTER TABLE Component DISABLE TRIGGER trig_cas_update_AssemblySubcomponent
				update Component set CategoryID=@cid where CategoryID=@dcid
			ALTER TABLE Component ENABLE TRIGGER trig_cas_update_AssemblySubcomponent

			delete Category where CategoryID = @dcid
		SET IDENTITY_INSERT Category OFF

END	
GO

----Cascade update for category to Supplier
--CREATE OR ALTER TRIGGER trig_cas_update_Sup ON Supplier
--INSTEAD OF UPDATE
--AS
--BEGIN
--	if UPDATE(SupplierID)
--		DECLARE @sid INT=(SELECT SupplierID FROM inserted)
--		DECLARE @dsid INT=(SELECT SupplierID FROM deleted)
--		DECLARE @sgst DECIMAL(2,2)=(select SupplierGST from Supplier where SupplierID = @dsid)

--		insert Supplier(SupplierID,SupplierGST) values (@sid,@sgst)

--		ALTER TABLE Component DISABLE TRIGGER trig_cas_update_AssemblySubcomponent
--			update Component set SupplierID=@sid where SupplierID=@dsid
--		ALTER TABLE Component ENABLE TRIGGER trig_cas_update_AssemblySubcomponent

--		delete Supplier where SupplierID = @dsid

--END	
--GO


CREATE OR ALTER TRIGGER trig_cas_update_AssemblySubcomponent ON Component
INSTEAD OF UPDATE
AS
BEGIN	 
	
	if UPDATE(ComponentID)
		ALTER TABLE AssemblySubcomponent
		DROP CONSTRAINT [FK_Assembly_Component];  --[FK_Subcomponent_Component]--[FK_Assembly_Component]

		ALTER TABLE AssemblySubcomponent
		DROP CONSTRAINT [FK_Subcomponent_Component];

		ALTER TABLE QuoteComponent
		DROP CONSTRAINT [FK_QuoteComponent_Component];
		--update Component ,   update AssemblySubcomponent,  update AssemblySubcomponent   
		DECLARE @id INT=(SELECT ComponentID FROM inserted)
		DECLARE @ComponentName NVARCHAR(100)=(SELECT ComponentName FROM deleted)
		DECLARE @ComponentDescription NVARCHAR(1500)=(SELECT ComponentDescription FROM deleted)
		DECLARE @SupplierID INT=(SELECT SupplierID FROM deleted)
		DECLARE @ListPrice DECIMAL(8,4)=(SELECT ListPrice FROM deleted)
		DECLARE @TradePrice DECIMAL(8,4)=(SELECT TradePrice FROM deleted)
		DECLARE @TimeToFit DECIMAL(10,2)=(SELECT TimeToFit FROM deleted)
		DECLARE @CategoryID INT=(SELECT CategoryID FROM deleted)

		SET IDENTITY_INSERT Component ON
			insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
			values (@id,@ComponentName,@ComponentDescription,@SupplierID,@ListPrice,@TradePrice,@TimeToFit,@CategoryID)
		SET IDENTITY_INSERT Component OFF
		
		UPDATE AssemblySubcomponent SET AssemblyID = @id
		FROM AssemblySubcomponent asseb JOIN deleted d ON asseb.AssemblyID = d.ComponentID

		UPDATE AssemblySubcomponent SET SubcomponentID = @id
		FROM AssemblySubcomponent asseb JOIN deleted d ON asseb.SubcomponentID = d.ComponentID

		UPDATE QuoteComponent SET ComponentID = @id
		FROM QuoteComponent qc JOIN deleted d ON qc.ComponentID = d.ComponentID

		DECLARE @delid INT=(SELECT ComponentID FROM deleted)
		delete Component where ComponentID = @delid
	
	
		ALTER TABLE AssemblySubcomponent
		with check
		ADD CONSTRAINT [FK_Assembly_Component] FOREIGN KEY (AssemblyID)
		REFERENCES Component(ComponentID)
		ON UPDATE NO ACTION
		ON DELETE NO ACTION

		ALTER TABLE AssemblySubcomponent
		with check
		ADD CONSTRAINT [FK_Subcomponent_Component] FOREIGN KEY (SubcomponentID)
		REFERENCES Component(ComponentID)
		ON UPDATE NO ACTION
		ON DELETE NO ACTION  

		ALTER TABLE QuoteComponent
		with check
		ADD CONSTRAINT [FK_QuoteComponent_Component] FOREIGN KEY (ComponentID) REFERENCES Component (ComponentID)
		ON UPDATE NO ACTION 
		ON DELETE NO ACTION

END	
GO

/*
select * from component
select * from supplier
select * from AssemblySubcomponent
select * from category
select * from Contact
SET IDENTITY_INSERT Component ON
update Category set CategoryID = 8 where CategoryID=1
update Supplier set SupplierID = 8 where SupplierID=1
update Component set ComponentID = 99999 where Componentid=30901
SET IDENTITY_INSERT Component OFF	
*/

CREATE OR ALTER PROC updateAssemblyPrices
AS
BEGIN
	ALTER TABLE Component DISABLE TRIGGER trig_cas_update_AssemblySubcomponent 
	UPDATE Component 
	SET TradePrice=totalprice.ttp, ListPrice=totalprice.tlp 
	FROM Component c JOIN
		(SELECT a.AssemblyID, SUM(c.TradePrice) AS 'ttp', SUM(c.ListPrice) AS 'tlp'
            FROM Component c JOIN AssemblySubcomponent a ON c.ComponentID=a.SubcomponentID
            GROUP BY a.AssemblyID) AS totalprice
	     ON c.ComponentID=totalprice.AssemblyID
	ALTER TABLE Component ENABLE TRIGGER trig_cas_update_AssemblySubcomponent
END
GO
--exec dbo.updateAssemblyPrices


CREATE OR ALTER TRIGGER trigSupplierDelete ON Supplier
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @id INT = (SELECT SupplierID FROM Supplier WHERE SupplierID=(SELECT SupplierID FROM deleted))
    DECLARE @count INT = (SELECT COUNT(ComponentID) FROM Component WHERE SupplierID=@id)
    DECLARE @name NVARCHAR(100)= (SELECT ContactName FROM Contact WHERE ContactID=@id)
	
	if(@count!=0)
		PRINT(N'You cannot delete this supplier. '+ @name + N' has ' + CAST(@count AS NVARCHAR) + N' related components.')
	else
		delete Supplier where SupplierID = @id
END
GO


--select * from Supplier
--select * from AssemblySubcomponent
--select * from Component
--delete from Supplier where SupplierID=1


go
CREATE OR ALTER PROC testCyclicAssembly(@assemblyID INT, @isCyclic INT OUTPUT)
AS
BEGIN
    DECLARE @temp table(AssemblyID int, SubcomponentID int)

    INSERT @temp(AssemblyID, SubcomponentID) 
    SELECT AssemblyID, SubcomponentID FROM AssemblySubcomponent WHERE AssemblyID = @assemblyID

	while @@ROWCOUNT > 0
    BEGIN	        
		INSERT @temp (AssemblyID, SubcomponentID)
        SELECT a.AssemblyID, a.SubcomponentID FROM @temp t JOIN AssemblySubcomponent a ON a.AssemblyID = t.SubcomponentID WHERE a.AssemblyID NOT IN (SELECT AssemblyID FROM @temp)
    END
    IF (SELECT COUNT(*) FROM @temp WHERE SubcomponentID=@assemblyID) > 0
		SET @isCyclic = 1;
    ELSE
        SET @isCyclic = 0;
END
RETURN @isCyclic
GO
/*
DECLARE @iscyclic INT
exec dbo.testCyclicAssembly 30935, @iscyclic output
print @iscyclic

INSERT AssemblySubcomponent (AssemblyID,SubcomponentID) VALUES (30901,30902)
INSERT AssemblySubcomponent (AssemblyID,SubcomponentID) VALUES (30902,30935)
*/

/*
select * from component
select * from supplier
select * from AssemblySubcomponent
select * from category
select * from Contact
*/