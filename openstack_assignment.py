import argparse
import openstack
import time

conn = openstack.connect(cloud_name='openstack')
servers = ['ganie1-web','ganie1-app','ganie1-db']

NETWORK_NAME = 'ganie1-net'
SECURITY_GROUP = 'default'
SUBNET = 'ganie1-subnet'
ROUTER = 'ganie1-rtr'


def create():
    ''' Create a set of Openstack resources '''
    public_net = conn.network.find_network(name_or_id='public-net')
    network = conn.network.find_network(NETWORK_NAME)
    subnet = conn.network.find_subnet(SUBNET)
    router = conn.network.find_router(ROUTER)
    if public_net is None:
        print('Could not find openstack public network')
    else:
        #create network if not exist
        if network:
            print('Network Exist')
        else:
            print('Network not found, creating new network')
            network = conn.network.create_network(name=NETWORK_NAME)
        #create subnet if not exist
        if subnet:
            print('Subnet Exist')
        else:
            print('Subnet not found, creating new subnet')
            subnet = conn.network.create_subnet(
                    network_id=network.id,
                    name=SUBNET,
                    ip_version='4',
                    cidr='192.168.50.0/24',
                    gateway_ip='192.168.50.1'
                    )

        #create router if not exist
        if router:
            print('Router Exist')
        else:
            print('Router not found, creating new router and adding subnet to router')
            router = conn.network.create_router(
                    name=ROUTER,
                    external_gateway_info={ 'network_id': public_net.id }
                    )
            conn.network.add_interface_to_router(router.id,subnet.id)

        #create server instances

        image = conn.compute.find_image('ubuntu-minimal-16.04-x86_64')
        flavor = conn.compute.find_flavor('c1.c1r1')
        keypair = conn.compute.find_keypair('ganie1-key')
        security_group = conn.network.find_security_group('default')
        if not keypair:
            print('keypair not found, please create a keypair and upload to the cloudcatalyst dashboard')
        else:
            for server in servers:
                serv = conn.compute.find_server(name_or_id=server)

                if serv:
                    print(server + ' Exist')
                    if server == 'ganie1-web':
                        serv = conn.compute.get_server(serv)

                        try:
                            serv['addresses'][NETWORK_NAME][1]['addr']
                        except IndexError:
                            print('ganie1-web does not have floating ip. Adding floating ip to ganie1-web')
                            floating_ip = conn.network.create_ip(floating_network_id=public_net.id)
                            conn.compute.add_floating_ip_to_server(serv,floating_ip.floating_ip_address)
                else:
                    serv = conn.compute.create_server(
                            name=server,
                            image_id=image.id,
                            flavor_id=flavor.id,
                            networks=[{'uuid':network.id}],
                            key_name=keypair.name,
                            security_groups=[security_group]
                            )
                    conn.compute.wait_for_server(serv)

                    if server == 'ganie1-web':
                        floating_ip = conn.network.create_ip(floating_network_id=public_net.id)
                        conn.compute.add_floating_ip_to_server(serv,floating_ip.floating_ip_address)
                        print('Floating ip ' + str(floating_ip.floating_ip_address) + ' added to ' + server)

                    print(server + ' created')

def run():
     ''' Start  a set of Openstack virtual machines
     if they are not already running.
     '''
     for server in servers:
        serv = conn.compute.find_server(name_or_id=server)
        if serv:
            serv = conn.compute.get_server(serv)
            if serv.status == 'ACTIVE':
                print(server+ ' is running')
            elif serv.status == 'SHUTOFF':
                print(server+ ' is off. starting server up')
                conn.compute.start_server(serv)
        else:
            print(server + ' not found')
			
			
			
def stop():
     ''' Stop  a set of Openstack virtual machines
     if they are running.
     '''
     for server in servers:
        serv = conn.compute.find_server(name_or_id=server)
        if serv:
            serv = conn.compute.get_server(serv)
            if serv.status == 'ACTIVE':
                print(server+ ' is running. Shutting off now')
                conn.compute.stop_server(serv)
            elif serv.status == 'SHUTOFF':
                print(server+ ' is off.')
        else:
            print(server + ' not found')

def destroy():
     ''' Tear down the set of Openstack resources
     produced by the create action
     '''
     for server in servers:
         serv = conn.compute.find_server(name_or_id=server)

         if serv:
             if server == 'ganie1-web':
                 serv = conn.compute.get_server(serv)
                 floating_ip = serv['addresses'][NETWORK_NAME][1]['addr']
                 conn.compute.remove_floating_ip_from_server(serv,floating_ip)
                 print('deleted floating ip ')

                 ip = conn.network.find_ip(floating_ip)
                 conn.network.delete_ip(ip)

                 print('deleted ip')

             conn.compute.delete_server(serv)
         else:
             print(server + ' does not exist')

     subnet = conn.network.find_subnet(SUBNET)
     router = conn.network.find_router(ROUTER)
     network = conn.network.find_network(NETWORK_NAME)

     if router:
         conn.network.remove_interface_from_router(router,subnet.id)
         conn.network.delete_router(router)
         print('Deleted router '+ROUTER)
         time.sleep(10)
     else:
         print(ROUTER+ ' router does not exist')
     time.sleep(10)
     if subnet:
         conn.network.delete_subnet(subnet)
         print('Deleted subnet' + SUBNET)
         time.sleep(10)
     else:
         print('SUBNET' + SUBNET+' does not exist')
     time.sleep(10)
     if network:
         for i in network.subnet_ids:
             conn.network.delete_subnet(subnet)
             print('delete subnet')
             time.sleep(10)
         conn.network.delete_network(network)
         print('Deleted network'+ NETWORK_NAME)
     else:
         print('Network' + NETWORK_NAME + ' does not exist')



def status():
    ''' Print a status report on the OpenStack
    virtual machines created by the create action.
    '''
    for server in servers:
        serv = conn.compute.find_server(name_or_id=server)
        if serv:
            serv = conn.compute.get_server(serv)
            print('Server: ' + serv.name + '\nStatus: '+ serv.status)
            for i in serv.addresses[NETWORK_NAME]:
                print(i['OS-EXT-IPS:type'].upper() +' IP: ' + i['addr'])
            print('\n')
        else:
            print('Server ' + server + ' not found')

if __name__ == '__main__':
        parser = argparse.ArgumentParser()
        parser.add_argument('operation',help='One of "create", "run", "stop", "destroy", or "status"')
        args = parser.parse_args()
        operation = args.operation

        operations = {
            'create'  : create,
            'run'     : run,
            'stop'    : stop,
            'destroy' : destroy,
            'status'  : status
            }
        action = operations.get(operation, lambda: print('{}: no such operation'.format(operation)))
        action()