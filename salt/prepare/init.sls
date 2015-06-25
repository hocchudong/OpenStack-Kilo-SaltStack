include:
  - prepare.ubuntu_repo
system_update:
  cmd.run:
    - name: apt-get update -y  && apt-get upgrade -y  && apt-get dist-upgrade -y