pkgs_neutron-network:
 pkg.installed:
  - refresh: False
  - pkgs:
{% for pkg in salt['pillar.get']('neutron-network:pkgs', []) %}
    - {{ pkg }}
{% endfor %}

config_ip_forward:
 cmd.run:
  - name: |
     echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
     echo "net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.conf
     echo "net.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.conf
     sysctl -p 
  - unless: cat /etc/sysctl.conf | grep -v ^$ | grep -v ^#

neutron.conf:
 file.managed:
  - name: /etc/neutron/neutron.conf
  - source: salt://neutron/network/files/neutron.conf
  - template: jinja
  - require:
     - pkg: pkgs_neutron-network

l3_agent.ini:
 file.managed:
  - name: /etc/neutron/l3_agent.ini
  - source: salt://neutron/network/files/l3_agent.ini
  - require:
     - pkg: pkgs_neutron-network

dhcp_agent.ini:
 file.managed:
  - name: /etc/neutron/dhcp_agent.ini
  - source: salt://neutron/network/files/dhcp_agent.ini
  - require:
     - pkg: pkgs_neutron-network

fix_mtu:
 cmd.run:
  - name: echo "dhcp-option-force=26,1454" > /etc/neutron/dnsmasq-neutron.conf
  - require:
    - file: dhcp_agent.ini
  - unless: cat /etc/neutron/dnsmasq-neutron.conf
     
metadata_agent.ini:
 file.managed:
  - name: /etc/neutron/metadata_agent.ini
  - source: salt://neutron/network/files/metadata_agent.ini
  - template: jinja
  - require:
     - pkg: pkgs_neutron-network

ml2_conf.ini:
 file.managed:
  - name: /etc/neutron/plugins/ml2/ml2_conf.ini
  - source: salt://neutron/network/files/ml2_conf.ini
  - require:
     - pkg: pkgs_neutron-network
  - template: jinja

{% for svc in salt['pillar.get']('neutron-network:services', []) %}
service_{{ svc }}:
 service.running:
  - name: {{ svc }}
  - require:
     - pkg: pkgs_neutron-network
  - watch:
     - file: neutron.conf
     - file: dhcp_agent.ini
     - file: l3_agent.ini
     - file: metadata_agent.ini
     - file: ml2_conf.ini
{% endfor %}

startup_service:
 cmd.run:
  - name: |
     sed -i "s/exit 0/# exit 0/g" /etc/rc.local
     echo "service openvswitch-switch restart" >> /etc/rc.local
     echo "service neutron-plugin-openvswitch-agent restart" >> /etc/rc.local
     echo "service neutron-l3-agent restart" >> /etc/rc.local
     echo "service neutron-dhcp-agent restart" >> /etc/rc.local
     echo "service neutron-metadata-agent restart" >> /etc/rc.local
     echo "service neutron-lbaas-agent restart" >> /etc/rc.local
     echo "exit 0" >> /etc/rc.local
  - unless: cat /etc/rc.local
  
openrc:
 file.managed:
  - name: /root/openrc
  - source: salt://keystone/files/openrc
  - template: jinja
