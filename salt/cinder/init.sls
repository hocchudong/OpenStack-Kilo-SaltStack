cinder_pkgs:
  pkg.installed:
   - refresh: False
   - pkgs:
{% for pkg in salt['pillar.get']('cinder:pkgs', []) %}
      - {{ pkg }}
{% endfor %}

#create_volume_group:
#  cmd.run:
#    - name: pvcreate /dev/vdb && vgcreate cinder-volumes /dev/vdb
#    - unless: fdisk -l

/dev/vdb:
  lvm.pv_present:
    - name: /dev/vdb

cinder-volumes:
  lvm.vg_present:
    - devices: /dev/vdb

cinder.conf:
  file.managed:
    - name: /etc/cinder/cinder.conf
    - user: cinder
    - group: cinder
    - mode: 644
    - source: salt://cinder/files/cinder.conf
    - template: jinja
    - require:
      - pkg: cinder_pkgs

config_lvm_config:
  cmd.run:
    - name: sed -r -e 's#(filter = )(\[ "a/\.\*/" \])#\1[ "a\/sda1\/", "a\/vdb\/", "r/\.\*\/"]#g' /etc/lvm/lvm.conf
    - unless: cat /etc/lvm/lvm.conf | grep filter

cinder_syndb:
 cmd.run:
  - name: cinder-manage db sync
  - unless: mysql -e 'show tables from {{ pillar['cinder']['dbname'] }}' | grep volume_types
  - require:
     - file: cinder.conf
    
{% for service in salt['pillar.get']('cinder:services', []) %}
service_{{ service }}:
 service.running:
  - name: {{ service }}
  - require:
     - pkg: cinder_pkgs
  - watch:
     - file: cinder.conf
     - cmd: cinder_syndb
{% endfor %}

