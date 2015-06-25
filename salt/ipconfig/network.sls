include:
  - neutron.openvswitch

eth0:
  network.managed:
    - enabled: True
    - type: eth
    - proto: static
    - ipaddr: {{ pillar['ipaddr']['mgnt']['network'] }}
    - netmask: {{ pillar['ipaddr']['netmask'] }}

br-ex:
  network.managed:
    - enabled: True
    - type: bridge
    - proto: static
    - ports: eth1
    - ipaddr: {{ pillar['ipaddr']['ext']['network'] }}
    - netmask: {{ pillar['ipaddr']['netmask'] }}
    - gateway: {{ pillar['ipaddr']['gateway'] }}
    - dns:
      - 8.8.8.8
      - 8.8.4.4
    - use:
      - network: eth1
eth1:
  network.managed:
    - enabled: True
    - type: eth
    - proto: manual
    - bridge: br-ex
      
eth2:
  network.managed:
    - enabled: True
    - type: eth
    - proto: static
    - ipaddr: {{ pillar['ipaddr']['data']['network'] }}
    - netmask: {{ pillar['ipaddr']['netmask'] }}
            
config_hostname:
  cmd.run:
    - name: |
        echo network > /etc/hostname && echo 127.0.0.1 network >> /etc/hosts
        init 6
