eth0:
  network.managed:
    - enabled: True
    - type: eth
    - proto: static
    - ipaddr: {{ pillar['ipaddr']['mgnt']['controller'] }}
    - netmask: {{ pillar['ipaddr']['netmask'] }}

eth1:
  network.managed:
    - enabled: True
    - type: eth
    - proto: static
    - ipaddr: {{ pillar['ipaddr']['ext']['controller'] }}
    - netmask: {{ pillar['ipaddr']['netmask'] }}
    - gateway: {{ pillar['ipaddr']['gateway'] }}
    - dns:
      - 8.8.8.8
      - 8.8.4.4

config_hostname:
  cmd.run:
    - name: |
        echo controller > /etc/hostname && echo 127.0.0.1 controller >> /etc/hosts
        init 6
