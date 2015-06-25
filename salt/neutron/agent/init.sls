neutron_agent_pkgs:
 pkg.installed:
   - refresh: False
   - pkgs:
{% for pkg in salt['pillar.get']('neutron-agent:pkgs', []) %}
      - {{ pkg }}
{% endfor %}

neutron-agent.conf:
 file.managed:
  - name: /etc/neutron/neutron.conf
  - user: root
  - group: root
  - mode: 644
  - source: salt://neutron/agent/files/neutron.conf
  - template: jinja
  - require:
     - pkg: neutron_agent_pkgs

ml2_conf.ini:
 file.managed:
  - name: /etc/neutron/plugins/ml2/ml2_conf.ini
  - user: root
  - group: root
  - mode: 644
  - source: salt://neutron/agent/files/ml2_conf.ini
  - template: jinja
  - require:
     - pkg: neutron_agent_pkgs     
          
{% for service in salt['pillar.get']('neutron-agent:services', []) %}
service_{{ service }}_restart:
  service.running:
   - name: {{ service}}
   - watch:
      - file: neutron-agent.conf
   - require:
      - pkg: neutron_agent_pkgs
{% endfor %}

# Create openrc
openrc:
 file.managed:
  - name: /root/openrc
  - source: salt://keystone/files/openrc
  - template: jinja