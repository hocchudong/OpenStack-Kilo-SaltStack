{% set OS_SERVICE_TOKEN=pillar['password'][3]['TOKEN_PASS'] %}
{% set OS_SERVICE_ENDPOINT='http://'~ salt['pillar.get']('ip:controller', '127.0.0.1') ~':35357/v2.0' %}
{% set keystone="keystone --os-token=" ~ OS_SERVICE_TOKEN ~ " --os-endpoint=" ~ OS_SERVICE_ENDPOINT %}

# Create tenant
{% for tenant in salt['pillar.get']('tenants', []) %}
tenant_{{ tenant['name'] }}:
 cmd.run:
  - name: {{ keystone }} tenant-create --name={{ tenant['name'] }} --description="{{ tenant['description'] }}"
  - unless: {{ keystone }} tenant-list | grep {{ tenant['name'] }}
{% endfor %}

# Create roles
{% for role in salt['pillar.get']('roles', []) %}
role_{{ role }}:
 cmd.run:
  - name: {{ keystone }} role-create --name={{ role }}
  - unless: {{ keystone }} role-list | grep {{ role }}
{% endfor %}


# Create User
{% for user in salt['pillar.get']('users', []) %}
user_{{ user['name'] }}:
 cmd.run:
{% for passwd in salt['pillar.get']('password', []) %}
{% if user['password'] in passwd %}
{% for key,val in passwd.iteritems()  %}
  - name: {{ keystone }} user-create --name={{ user['name'] }} --pass={{ val }} --email={{ user['email'] }}
{% endfor %}
{% endif %}
{% endfor %}
  - unless: {{ keystone }} user-list | grep {{ user['name'] }}

# Assign roles for a user
{% for role in user['roles'] %}
role_{{ user['name'] }}_{{ role }}:
 cmd.run:
  - name: {{ keystone }} user-role-add --user {{ user['name'] }}  --tenant {{ user['tenant'] }} --role {{ role }}
  - unless: {{ keystone }} user-role-list --user {{ user['name'] }} --tenant {{ user['tenant'] }} | grep $({{ keystone }} user-list | grep {{ user['name'] }} | awk '{print $2}')
  - require:
     - cmd: user_{{ user['name'] }}
     - cmd: role_{{ role }}
     - cmd: tenant_{{ user['tenant']}}
{% endfor %}
{% endfor %}


#Create services
{% for service in salt['pillar.get']('services', []) %}
service_{{ service['name'] }}:
 cmd.run:
  - name: {{ keystone }} service-create --name={{ service['name'] }} --description="{{ service['description'] }}" --type {{ service['type'] }}
  - unless: {{ keystone }} service-list | grep {{ service['name'] }}
{% endfor %}


# Create endpoint
{% for endpoint in salt['pillar.get']('endpoints', []) %}
endpoint_{{ endpoint['name'] }}:
 cmd.run:
  - name: {{ keystone }} endpoint-create --service-id $({{ keystone }} service-list | awk '/ {{ endpoint['type'] }} / {print $2}') --publicurl {{ endpoint['publicurl'] }} --internalurl {{ endpoint['internalurl'] }} --adminurl {{ endpoint['adminurl'] }}
  - unless: {{ keystone }} endpoint-list | grep $({{ keystone }} service-list | awk '/ {{ endpoint['type'] }} / {print $2}')
  - require:
     - cmd: service_{{ endpoint['name']}}
{% endfor %}


# Create openrc
openrc:
 file.managed:
  - name: /root/openrc
  - source: salt://keystone/files/openrc
  - template: jinja
