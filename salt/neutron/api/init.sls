pkgs_neutron-api-server:
 pkg.installed:
  - refresh: False
  - pkgs:
{% for pkg in salt['pillar.get']('neutron-api-server:pkgs', []) %}
     - {{ pkg }}
{% endfor %} 

neutron.conf:
 file.managed:
  - name: /etc/neutron/neutron.conf
  - source: salt://neutron/api/files/neutron.conf
  - template: jinja
  - require:
     - pkg: pkgs_neutron-api-server

{% set OS_SERVICE_TOKEN=pillar['password'][3]['TOKEN_PASS'] %}
{% set OS_SERVICE_ENDPOINT='http://'~ salt['pillar.get']('ip:controller', '127.0.0.1') ~':35357/v2.0' %}
{% set keystone="keystone --os-token=" ~ OS_SERVICE_TOKEN ~ " --os-endpoint=" ~ OS_SERVICE_ENDPOINT %}

nova_admin_tenant_id:
 cmd.run:
  - name: sed -r -i "s/^nova_admin_tenant_id.*/nova_admin_tenant_id = $({{ keystone }} tenant-get service | awk '/ id / {print $4}')/" /etc/neutron/neutron.conf
  - require:
     - file: neutron.conf

ml2_conf.ini:
 file.managed:
  - name: /etc/neutron/plugins/ml2/ml2_conf.ini
  - source: salt://neutron/api/files/ml2_conf.ini
  - require:
     - pkg: pkgs_neutron-api-server

neutron_command:
 cmd.run:
  - name: su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
  - require:
     - file: neutron.conf

{% for svc in salt['pillar.get']('neutron-api-server:services', []) %}
{{ svc }}:
 service.running:
  - name: {{ svc }}
  - require:
     - pkg: pkgs_neutron-api-server
     - cmd: nova_admin_tenant_id
  - watch:
     - file: neutron.conf
     - file: ml2_conf.ini
{% endfor %}

{% for svc in ['nova-scheduler', 'nova-conductor', 'nova-api'] %}
neutron-api_{{ svc }}:
 service.running:
  - name: {{ svc }}
  - watch:
     - file: neutron.conf
{% endfor %}
