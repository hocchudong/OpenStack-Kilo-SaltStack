ntp:
 pkg:
  - installed
  - refresh: False
  - name: ntp
ntp.conf:
 file.managed:
  - name: /etc/ntp.conf
  - user: root
  - group: root
  - mode: 644
  - template: jinja
{% if 'controller' in grains['id'] %}
  - source: salt://ntp/files/ntp-controller.conf
{% else %}
  - source: salt://ntp/files/ntp.conf
{% endif %}
 service.running:
  - name: ntp
  - watch:
    - file: ntp.conf
  - require:
    - pkg: ntp
