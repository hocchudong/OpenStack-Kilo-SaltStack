ubuntu_cloud_keyring_install:
  pkg:
    - installed
    - name: ubuntu-cloud-keyring
    - refresh: True

cloudarchive_juno:
  file.managed:
    - name: /etc/apt/sources.list.d/cloudarchive-kilo.list
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - source: salt://prepare/files/cloudarchive-kilo.list

run_command_tee:
  cmd.run:
    - name: tee /etc/apt/sources.list.d/cloud-archive.list