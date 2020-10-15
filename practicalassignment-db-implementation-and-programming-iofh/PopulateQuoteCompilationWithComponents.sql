/*  START  */

/*
Create data on QuoteCompilation database to support
IN705 Databases 3 assignment.

****************************WARNING******************************************************
Object names used in this script require that
you must have implemented the database as specified on the assignment ERD


*/

--support functions, views and sp
--create function dbo.getCategoryID
--create function dbo.getAssemblySupplierID()
--create proc addSubComponent
-- Using variables : @ABC int, @XYZ int, @CDBD int, @BITManf int- capture the ContactID

--create categories

DECLARE @ABC INT
DECLARE @XYZ INT
DECLARE @CDBD INT
DECLARE @BITManf INT


insert Category (CategoryName) values ('Black Steel')
insert Category (CategoryName) values ('Assembly')
insert Category (CategoryName) values ('Fixings')
insert Category (CategoryName) values ('Paint')
insert Category (CategoryName) values ('Labour')


--create contacts
--Using variables : @ABC int, @XYZ int, @CDBD int, @BITManf int- capture the ContactID
-- This will mean you don't have to hard code these later.

insert Contact (ContactName, ContactPostalAddress, ContactWWW, ContactEmail, ContactPhone, ContactFax)
values ('ABC Ltd.', '17 George Street, Dunedin', 'www.abc.co.nz', 'info@abc.co.nz', '	471 2345', null)
SET @ABC = @@IDENTITY

--populate supplierid using @@identity
INSERT Supplier(SupplierID) VALUES (@ABC)

insert Contact (ContactName, ContactPostalAddress, ContactWWW, ContactEmail, ContactPhone, ContactFax)
values ('XYZ Ltd.', '23 Princes Street, Dunedin', null, 'xyz@paradise.net.nz', '4798765', '4798760')
SET @XYZ = @@IDENTITY

INSERT Supplier(SupplierID) VALUES (@XYZ)

insert Contact (ContactName, ContactPostalAddress, ContactWWW, ContactEmail, ContactPhone, ContactFax)
values ('CDBD Pty Ltd.',	'Lot 27, Kangaroo Estate, Bondi, NSW, Australia 2026', '	www.cdbd.com.au', 'support@cdbd.com.au', '+61 (2) 9130 1234', null)
SET @CDBD = @@IDENTITY

INSERT Supplier(SupplierID) VALUES (@CDBD)

insert Contact (ContactName, ContactPostalAddress, ContactWWW, ContactEmail, ContactPhone, ContactFax)
values ('BIT Manufacturing Ltd.', 'Forth Street, Dunedin', 'bitmanf.tekotago.ac.nz', 'bitmanf@tekotago.ac.nz', '0800 SMARTMOVE', null)
SET @BITManf = @@IDENTITY

INSERT Supplier(SupplierID)VALUES (@BITManf)

-- create components
-- Note this script relies on you having captured the ContactID to insert into SupplierID
SET IDENTITY_INSERT Component ON
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30901, 'BMS10', '10mm M6 ms bolt', @ABC, 0.20, 0.17, 0.5, dbo.getCategoryID('Fixings'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30902, 'BMS12', '12mm M6 ms bolt', @ABC, 0.25, 0.2125,	0.5, dbo.getCategoryID('Fixings'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30903, 'BMS15', '15mm M6 ms bolt', @ABC, 0.32, 0.2720, 0.5, dbo.getCategoryID('Fixings'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30904, 'NMS10', '10mm M6 ms nut', @ABC, 0.05, 0.04, 0.5, dbo.getCategoryID('Fixings'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30905, 'NMS12', '12mm M6 ms nut', @ABC, 0.052, 0.0416, 0.5, dbo.getCategoryID('Fixings'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30906, 'NMS15', '15mm M6 ms nut', @ABC, 0.052, 0.0416, 0.5, dbo.getCategoryID('Fixings'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30911, 'BMS.3.12', '3mm x 12mm flat ms bar', @XYZ, 1.20, 1.15, 	0.75, dbo.getCategoryID('Black Steel'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30912, 'BMS.5.15', '5mm x 15mm flat ms bar', @XYZ, 2.50, 2.45, 	0.75, dbo.getCategoryID('Black Steel'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30913, 'BMS.10.25', '10mm x 25mm flat ms bar', @XYZ, 8.33, 8.27, 0.75, dbo.getCategoryID('Black Steel'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30914, 'BMS.15.40', '15mm x 40mm flat ms bar', @XYZ, 20.00, 19.85, 0.75, dbo.getCategoryID('Black Steel'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30931, '27', 'Anti-rust paint, silver', @CDBD, 74.58, 63.85, 0, dbo.getCategoryID('Paint'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30932, '43', 'Anti-rust paint, red', @CDBD, 74.58, 63.85, 0, dbo.getCategoryID('Paint'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30933, '154', 'Anti-rust paint, blue', @CDBD, 74.58, 63.85, 0, dbo.getCategoryID('Paint'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30921, 'ARTLAB', 'Artisan labour', @BITManf, 42.00, 42.00, 0	, dbo.getCategoryID('Labour'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30922, 'DESLAB', 'Designer labour', @BITManf, 54.00, 54.00, 0, dbo.getCategoryID('Labour'))
insert Component (ComponentID, ComponentName, ComponentDescription, SupplierID, ListPrice, TradePrice, TimeToFit, CategoryID)
values (30923, 'APPLAB', 'Apprentice labour', @BITManf, 23.50, 23.50, 0, dbo.getCategoryID('Labour'))

SET IDENTITY_INSERT Component OFF



--create assemblies

exec createAssembly  'SmallCorner.15', '15mm small corner'
exec dbo.addSubComponent 'SmallCorner.15', 'BMS.5.15', 0.120
exec dbo.addSubComponent 'SmallCorner.15', 'APPLAB', 0.33333
exec dbo.addSubComponent 'SmallCorner.15', '43', 0.0833333

exec dbo.createAssembly 'SquareStrap.1000.15', '1000mm x 15mm square strap'
exec dbo.addSubComponent 'SquareStrap.1000.15', 'BMS.5.15', 4
exec dbo.addSubComponent 'SquareStrap.1000.15', 'SmallCorner.15', 4
exec dbo.addSubComponent 'SquareStrap.1000.15', 'APPLAB', 25
exec dbo.addSubComponent 'SquareStrap.1000.15', 'ARTLAB', 10
exec dbo.addSubComponent 'SquareStrap.1000.15', '43', 0.185
exec dbo.addSubComponent 'SquareStrap.1000.15', 'BMS10', 8

exec dbo.createAssembly 'CornerBrace.15', '15mm corner brace'
exec dbo.addSubComponent 'CornerBrace.15', 'BMS.5.15', 0.090
exec dbo.addSubComponent 'CornerBrace.15', 'BMS10', 2



--drop functions, views and sp
/*
drop proc createAssembly
drop proc addSubComponent
drop function dbo.getCategoryID
drop function dbo.getAssemblySupplierID
*/


-- populate table using stored procedures


DECLARE @customer INT
DECLARE @quote INT
exec @customer = dbo.createCustomer 'Bimble & Hat','444 5555','123 Digit Street, Dunedin ',' guy.little@bh.biz.nz', NULL, NULL, NULL, NULL

exec @quote = dbo.createQuote 'Craypot frame', NULL, NULL, @customer, NULL
exec addQuoteComponent @quote, 30935,3
exec addQuoteComponent @quote, 30912,8
exec addQuoteComponent @quote, 30901,24
exec addQuoteComponent @quote, 30904,24
exec addQuoteComponent @quote, 30933,200
exec addQuoteComponent @quote, 30921, 150
exec addQuoteComponent @quote, 30923, 120
exec addQuoteComponent @quote, 30922, 45

exec @quote = createQuote 'Craypot stand', NULL,  NULL, @customer, NULL
exec addQuoteComponent @quote, 30914, 2
exec addQuoteComponent @quote, 30903, 4
exec addQuoteComponent @quote, 30906, 4
exec addQuoteComponent @quote, 30933, 100
exec addQuoteComponent @quote, 30923, 90
exec addQuoteComponent @quote, 30922, 15

exec @customer = createCustomer 'Hyperfont Modulator (International) Ltd.', '(4)213 4359', '3 Lambton Quay, Wellington', 'sue@nz.hfm.com', NULL, NULL, NULL, NULL
exec @quote = createQuote 'Phasing restitution fulcrum', NULL,  NULL, @customer, NULL
exec addQuoteComponent @quote, 30936, 3
exec addQuoteComponent @quote, 30934, 1
exec addQuoteComponent @quote, 30921, 320
exec addQuoteComponent @quote, 30922, 0.5
exec addQuoteComponent @quote, 30932, 1000
