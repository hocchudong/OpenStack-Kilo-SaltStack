rabbitmq_repo:
  file.managed:
    - name: /etc/apt/sources.list.d/rabbitmq.list
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - source: salt://rabbit/files/rabbitmq.list

run_command:
  cmd.run:
    - name: apt-get update