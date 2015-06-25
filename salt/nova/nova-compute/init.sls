nova-compute_pkgs:
 pkg.installed:
   - refresh: False
   - pkgs:
{% for pkg in salt['pillar.get']('nova-compute:pkgs', []) %}
      - {{ pkg }}
{% endfor %}

#kernel_statoverride:
# file.managed:
#  - name: /etc/kernel/postinst.d/statoverride
#  - user: root
#  - group: root
#  - mode: 755
#  - source: salt://nova/nova-compute/files/statoverride

config_ip_forward:
 cmd.run:
  - name: |
     echo "net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.conf
     echo "net.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.conf
     sysctl -p
  - unless: cat /etc/sysctl.conf | grep -v ^$ | grep -v ^#

nova-compute.conf:
 file.managed:
  - name: /etc/nova/nova.conf
  - user: nova
  - group: nova
  - mode: 640
  - source: salt://nova/nova-compute/files/nova.conf
  - template: jinja
  - require:
     - pkg: nova-compute_pkgs

fix_bug:
 cmd.run:
  - name: |
     rm /var/lib/nova/nova.sqlite
     echo 'kvm_intel' >> /etc/modules
     
{% for service in salt['pillar.get']('nova-compute:service', []) %}
service_{{ service }}:
  service.running:
   - name: {{ service}}
   - watch:
      - file: nova-compute.conf
   - require:
      - pkg: nova-compute_pkgs
{% endfor %}
