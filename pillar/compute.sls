{% set COM_MGNT_IP = grains['ip_interfaces']['eth0'][0] %}
{% set COM_EXT_IP = grains['ip_interfaces']['eth1'][0] %}
{% set COM_DATA_IP = grains['ip_interfaces']['eth2'][0] %}

ipcompute:
 mgnt: {{ COM_MGNT_IP }}
 ext: {{ COM_EXT_IP }}
 data: {{ COM_DATA_IP }}

nova-compute:
 pkgs:
  - nova-compute 
  - sysfsutils
  - libguestfs-tools 
 service:
  - nova-compute

neutron-agent:
 pkgs:
  - neutron-common 
  - neutron-plugin-ml2 
  - neutron-plugin-openvswitch-agent  
 services:
  - nova-compute 
  - openvswitch-switch
  - neutron-plugin-openvswitch-agent
 