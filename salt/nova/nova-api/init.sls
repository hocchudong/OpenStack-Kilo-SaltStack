nova-api_pkgs:
 pkg.installed:
   - refresh: False
   - pkgs:
{% for pkg in salt['pillar.get']('nova-api:pkgs', []) %}
      - {{ pkg }}
{% endfor %}

nova.conf:
 file.managed:
  - name: /etc/nova/nova.conf
  - mode: 640
  - user: nova
  - group: nova
  - source: salt://nova/nova-api/files/nova.conf
  - template: jinja

nova.sqlite:
 file.absent:
  - name: /var/lib/nova/nova.sqlite
  - require:
     - pkg: nova-api_pkgs


nova_dbsync:
 cmd.run:
  - name: nova-manage db sync
  - unless: mysql -e 'show tables from {{ pillar['nova-api']['dbname'] }}' | grep aggregate_hosts
  - require:
     - file: nova.conf
     - pkg: nova-api_pkgs

{% for service in salt['pillar.get']('nova-api:services', [])%}
service_{{ service }}:
 service.running:
  - name: {{ service }}
  - require:
     - pkg: nova-api_pkgs
  - watch:
     - file: nova.conf
     - cmd: nova_dbsync
{% endfor %}

