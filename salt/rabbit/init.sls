include:
  - rabbit.rabbit_repo

add_key_rabbit:
  cmd.run:
    - name: curl -O https://www.rabbitmq.com/rabbitmq-signing-key-public.asc && apt-key add rabbitmq-signing-key-public.asc
  
update_rabbit:
  cmd.run:
    - name: apt-get update --force-yes
  
{% for pkg in salt['pillar.get']('rabbit:pkgs', []) %}
pkg_{{ pkg }}:
 pkg.installed:
  - refresh: False
  - name: {{ pkg }}
{% endfor %}

 service.running:
  - name: rabbitmq-server
  - require:
     - pkg: rabbitmq-server
 
 cmd.run:
  - name: rabbitmqctl add_user openstack {{ pillar['password'][1]['RABBIT_PASS']}} && rabbitmqctl set_permissions openstack ".*" ".*" ".*"
  - require:
     - service: rabbitmq-server