eth0:
  network.managed:
    - enabled: True
    - type: eth
    - proto: static
    - ipaddr: {{ pillar['ipaddr']['mgnt']['compute1'] }}
    - netmask: {{ pillar['ipaddr']['netmask'] }}

eth1:
  network.managed:
    - enabled: True
    - type: eth
    - proto: static
    - ipaddr: {{ pillar['ipaddr']['ext']['compute1'] }}
    - netmask: {{ pillar['ipaddr']['netmask'] }}
    - gateway: {{ pillar['ipaddr']['gateway'] }}
    - dns:
      - 8.8.8.8
      - 8.8.4.4

      
eth2:
  network.managed:
    - enabled: True
    - type: eth
    - proto: static
    - ipaddr: {{ pillar['ipaddr']['data']['compute1'] }}
    - netmask: {{ pillar['ipaddr']['netmask'] }}


config_hostname:
  cmd.run:
    - name: |
        echo compute1 > /etc/hostname && echo 127.0.0.1 compute1 >> /etc/hosts
        init 6
