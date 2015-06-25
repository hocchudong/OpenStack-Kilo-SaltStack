{% set NET_MGNT_IP = grains['ip_interfaces']['eth0'][0] %}
{% set NET_EXT_IP = grains['ip_interfaces']['eth1'][0] %}
{% set NET_EXT_IP = grains['ip_interfaces']['eth2'][0] %}

#IP config
ipnetwork:
 mgnt: {{ NET_MGNT_IP }}
 ext: {{ NET_EXT_IP }}
 data: {{ NET_EXT_IP }}

neutron-network:
 pkgs:
  - neutron-common
  - neutron-plugin-ml2
  - neutron-plugin-openvswitch-agent
  - neutron-l3-agent
  - neutron-dhcp-agent
  - neutron-metadata-agent
  - neutron-plugin-openvswitch 
 external_if: eth1
 services:
  - openvswitch-switch
  - neutron-plugin-openvswitch-agent
  - neutron-l3-agent
  - neutron-dhcp-agent
  - neutron-metadata-agent

neutron-openvswitch:
 pkgs:
  - openvswitch-switch
  - python-mysqldb
