include:
  - prepare

{% for pkg in salt['pillar.get']('neutron-openvswitch:pkgs', []) %}
pkg_{{ pkg }}:
 pkg.installed:
  - refresh: False
  - name: {{ pkg }}
{% endfor %}

add-port:
  cmd.run:
    - name: |
        ovs-vsctl add-br br-ex
        ovs-vsctl add-port br-ex {{pillar['neutron-network']['external_if']}}
    - unless: ovs-vsctl list-br | grep br-ex 
