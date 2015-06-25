glance_pkgs:
 pkg.installed:
  - refresh: False
  - pkgs:
{% for pkg in salt['pillar.get']('glance:pkgs', []) %}
     - {{ pkg }}
{% endfor %}

glance-api.conf:
 file.managed:
  - name: /etc/glance/glance-api.conf
  - source: salt://glance/files/glance-api.conf
  - mode: 644
  - user: glance
  - group: glance
  - template: jinja
  - require:
     - pkg: glance_pkgs

glance-registry.conf:
 file.managed:
  - name: /etc/glance/glance-registry.conf
  - source: salt://glance/files/glance-registry.conf
  - mode: 644
  - user: glance
  - group: glance
  - template: jinja
  - require:
     - pkg: glance_pkgs

glance.sqlite:
 file.absent:
  - name: /var/lib/glance/glance.sqlite
  - require:
     - pkg: glance_pkgs

glance_dbsync:
 cmd.run:
  - name: glance-manage db_sync
  - unless: mysql -e 'show tables from glance' | grep images
  - require:
     - file: glance-registry.conf
     - file: glance-api.conf

{% for service in salt['pillar.get']('glance:services', []) %}
service_{{ service }}:
 service.running:
  - name: {{ service }}
  - require:
     - pkg: glance_pkgs
  - watch:
     - file: {{ service }}.conf
#     - cmd: glance_dbsync
{% endfor %}

download_cirros_image:
 cmd.run:
  - name: wget {{ pillar['glance']['cirros_url'] }}
  - unless: rm cirros-0.3.3-x86_64-disk.img && wget {{ pillar['glance']['cirros_url'] }}

create_image_cirros:
 cmd.run:
  - name: glance image-create --name "cirros-0.3.3-x86_64" --disk-format qcow2 --container-format bare --is-public True --progress < /root/cirros-0.3.3-x86_64-disk.img
  - unless: echo "Image Cirros already exists!"
