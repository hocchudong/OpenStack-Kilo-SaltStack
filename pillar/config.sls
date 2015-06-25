#IP address
ipaddr:
  mgnt:
    controller: '10.10.10.61'
    network: '10.10.10.62'
    compute1: '10.10.10.63'
    compute2: '10.10.10.64'
  ext:
    controller: '192.168.1.61'
    network: '192.168.1.62'
    compute1: '192.168.1.63'
    compute2: '192.168.1.64'
  data:
    controller: '10.10.20.61'
    network: '10.10.20.62'
    compute1: '10.10.20.63'
    compute2: '10.10.20.64'
  netmask: '255.255.255.0'
  gateway: '192.168.1.1'
  
# Hostname
hostname:
  controller: controller
  network: network
  compute1: compute1
  compute2: compute2
  
# Set password 
password:
  - DEFAULT_PASS: Welcome123
  - RABBIT_PASS: Welcome123
  - MYSQL_PASS: Welcome123
  - TOKEN_PASS: Welcome123
  - ADMIN_PASS: Welcome123
  - DEMO_PASS: Welcome123
  - SERVICE_PASSWORD: Welcome123
  - METADATA_SECRET: Welcome123

  - KEYSTONE_PASS: Welcome123
  - GLANCE_PASS: Welcome123
  - NOVA_PASS: Welcome123
  - NEUTRON_PASS: Welcome123
  - CINDER_PASS: Welcome123  
  
dbpassword:
  - KEYSTONE_DBPASS: Welcome1234
  - GLANCE_DBPASS: Welcome123
  - NOVA_DBPASS: Welcome123
  - NEUTRON_DBPASS: Welcome123
  - CINDER_DBPASS: Welcome123  
  
