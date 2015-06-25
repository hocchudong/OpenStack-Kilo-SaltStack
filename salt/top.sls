base:
  'controller':
    - prepare
    - ntp
    - rabbit
    - mysql
    - keystone
    - keystone.create-user-tenant
    - glance
    - nova.nova-api
    - neutron.api
    - cinder
    - horizon

  'network':
#    - prepare
    - ntp
    - python-mysql
    - neutron.network
    
  'compute*':
    - prepare
    - ntp
    - python-mysql
    - nova.nova-compute
    - neutron.agent
