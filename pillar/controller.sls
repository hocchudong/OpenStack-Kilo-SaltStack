#IP
{% set CON_MGNT_IP = grains['ip_interfaces']['eth0'][0] %}
{% set CON_EXT_IP = grains['ip_interfaces']['eth1'][0] %}

ip:
  controller: {{ CON_MGNT_IP }}
  ext_ip: {{ CON_EXT_IP }}

#Rabbit
rabbit:
  pkgs:
    - rabbitmq-server

#Mysql    
mysql:
  server:
    config_file: salt://mysql/files/my.cnf
    bind-address: 0.0.0.0
    port: 3306
  users:
    - name: keystone
      host: ['localhost', '%']
      password: KEYSTONE_DBPASS
      privileges: all privileges
      database_name: keystone
    - name: cinder
      host: ['localhost', '%']
      password: CINDER_DBPASS
      privileges: all privileges
      database_name: cinder
    - name: nova
      host: ['localhost', '%']
      password: NOVA_DBPASS
      privileges: all privileges
      database_name: nova
    - name: glance
      host: ['localhost', '%']
      password: GLANCE_DBPASS
      privileges: all privileges
      database_name: glance
    - name: neutron
      host: ['localhost', '%']
      password: NEUTRON_DBPASS
      privileges: all privileges
      database_name: neutron
  databases:
    - keystone
    - cinder
    - nova
    - glance
    - neutron

# Keystone
keystone:
  pkgs:
    - keystone
    - python-keystoneclient
  dbname: 'keystone'
  dbuser: 'keystone'
    
tenants:
  - name: demo
    description: DEMO_TENANT_NAME
  - name: admin
    description: ADMIN_TENANT_NAME
  - name: service
    description: SERVICE_TENANT_NAME
  - name: invisible_to_admin
    description: INVIS_TENANT_NAME
    
roles:
  - admin
  - Member
  - KeystoneAdmin
  - KeystoneServiceAdmin
  
users:
  - name: admin
    password: ADMIN_PASS
    tenant: admin
    roles: ['admin', 'Member']
    email: ducnc92@hotmail.com
  - name: demo
    password: DEMO_PASS
    tenant: demo
    roles: ['admin', 'Member']
    email: ducnc92@hotmail.com
  - name: glance
    password: GLANCE_PASS
    tenant: service
    roles: ['admin']
    email: ducnc92@hotmail.com
  - name: cinder
    password: CINDER_PASS
    tenant: service
    roles: ['admin']
    email: ducnc92@hotmail.com
  - name: nova
    password: NOVA_PASS
    tenant: service
    roles: ['admin']
    email: ducnc92@hotmail.com
  - name: neutron
    password: NEUTRON_PASS
    tenant: service
    roles: ['admin']
    email: ducnc92@hotmail.com

services:
  - name: glance
    description: OpenStack Image Service
    type: image
  - name: keystone
    description: OpenStack Identity
    type: identity
  - name: nova
    description: OpenStack Compute
    type: compute
  - name: cinder
    description: OpenStack Block Storage
    type: volume
  - name: cinderv2
    description: OpenStack Block Storage v2
    type: volumev2
  - name: neutron
    description: OpenStack Networking
    type: network

endpoints:
  - name: keystone
    publicurl: 'http://{{ CON_MGNT_IP }}:5000/v2.0'
    internalurl: 'http://{{ CON_MGNT_IP }}:5000/v2.0'
    adminurl: 'http://{{ CON_MGNT_IP }}:35357/v2.0'
    type: identity

  - name: glance
    publicurl: 'http://{{ CON_MGNT_IP }}:9292'
    internalurl: 'http://{{ CON_MGNT_IP }}:9292'
    adminurl: 'http://{{ CON_MGNT_IP }}:9292'
    type: image

  - name: nova
    publicurl: 'http://{{ CON_MGNT_IP }}:8774/v2/%\(tenant_id\)s'
    internalurl: 'http://{{ CON_MGNT_IP }}:8774/v2/%\(tenant_id\)s'
    adminurl: 'http://{{ CON_MGNT_IP }}:8774/v2/%\(tenant_id\)s'
    type: compute

  - name: cinder
    publicurl: 'http://{{ CON_MGNT_IP }}:8776/v1/%\(tenant_id\)s'
    internalurl: 'http://{{ CON_MGNT_IP }}:8776/v1/%\(tenant_id\)s'
    adminurl: 'http://{{ CON_MGNT_IP }}:8776/v1/%\(tenant_id\)s'
    type: volume

  - name: cinderv2
    publicurl: 'http://{{ CON_MGNT_IP }}:8776/v2/%\(tenant_id\)s'
    internalurl: 'http://{{ CON_MGNT_IP }}:8776/v2/%\(tenant_id\)s'
    adminurl: 'http://{{ CON_MGNT_IP }}:8776/v2/%\(tenant_id\)s'
    type: volumev2

  - name: neutron
    publicurl: 'http://{{ CON_MGNT_IP }}:9696'
    internalurl: 'http://{{ CON_MGNT_IP }}:9696'
    adminurl: 'http://{{ CON_MGNT_IP }}:9696'
    type: network

    
#Glance
glance:
  pkgs:
    - glance
    - python-glanceclient
  cirros_url: http://download.cirros-cloud.net/0.3.3/cirros-0.3.3-x86_64-disk.img
  services:
    - glance-registry
    - glance-api


#Nova  
nova-api:
  pkgs:
    - nova-api
    - nova-cert
    - nova-conductor
    - nova-consoleauth
    - nova-novncproxy
    - nova-scheduler
    - python-novaclient
    - libguestfs-tools
  dbname: 'nova'
  dbuser: 'nova'
  services:
    - nova-api
    - nova-cert
    - nova-consoleauth
    - nova-scheduler
    - nova-conductor
    - nova-novncproxy

  
#Neutron  
neutron-api-server:
  pkgs:
    - neutron-server
    - neutron-plugin-ml2
    - python-neutronclient
  services:
    - neutron-server


#Cinder
cinder:
  pkgs:
    - lvm2
    - cinder-api
    - cinder-scheduler
    - cinder-volume
    - iscsitarget
    - open-iscsi
    - iscsitarget-dkms
    - python-cinderclient
  dbname: 'cinder'
  dbuser: 'cinder'
  tenant: service
  username: cinder
  services:
    - cinder-api
    - cinder-scheduler
    - cinder-volume
    
    
#Horizon
horizon:
  pkgs:
    - openstack-dashboard 
    - memcached
  absent_pkgs:
    - openstack-dashboard-ubuntu-theme
  services:
    - apache2 
    - memcached
