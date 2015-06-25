{% if 'controller' in grains['id'] %}
include:
  - ipconfig.controller
{% elif 'network' in grains['id'] %}
include:
  - ipconfig.network
{% else %}
include:
  - ipconfig.{{ grains['id'] }}
{% endif %}
