git:
  pkg:
    - installed
    - refresh:
        true

python-pip:
  pkg:
    - installed

python-redis:
  pkg:
    - installed

apache2:
  pkg:
    - installed
  service:
    - running
    - enable: true
    - watch:
      - file: /etc/apache2/sites-available/000-default.conf
    - require:
      - pkg: apache2

apache_git:
  file.managed:
    - name: /etc/apache2/sites-available/000-default.conf
    - source: salt://files/deployment.conf

redis-server:
  pkg:
    - installed
  service:
    - running
    - enable: true
    - watch:
      - file: /etc/redis/redis.conf
    - require:
      - pkg: redis-server

/etc/redis/redis.conf:
  file.comment:
    - regex: ^bind 127.0.0.1

/home/vagrant/.gitconfig:
  file.managed:
    - user: vagrant
    - group: vagrant
    - mode: 644
    - source: salt://files/gitconfig

/srv/deployment:
  file:
    - directory
    - user: vagrant
    - group: vagrant
    - dir_mode: 755
    - file_mode: 644

TrebuchetTrigger:
  pip:
    - installed

site:
  grains:
    - present
    - value: dev

deployment_server:
  grains:
    - present
    - value: true

deployment_repo_user:
  grains:
    - present
    - value: vagrant

sync_all:
  module.run:
    - name: deploy.deployment_server_init
