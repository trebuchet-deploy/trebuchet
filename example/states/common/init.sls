# Salt and salt dependencies
Ensure python dependencies are installed:
  pkg.installed:
    - pkgs:
      - python-virtualenv
      - python-pip
      - python-apt
      - python-dev

Ensure trebuchet dependencies are installed:
  pkg.installed:
    - pkgs:
      - git-core
      - python-redis

Ensure salt virtualenv is managed:
  virtualenv.managed:
    - name: /srv/salt/venv
    # Switch to the existing salt venv
    - pip_exists_action: s
    - system_site_packages: True
    - requirements: /srv/trebuchet/requirements.txt
    - reload_modules: True

{% for command in ['salt-call', 'salt-minion'] %}
Ensure {{ command }} link exists:
  file.symlink:
    - name: /usr/local/bin/{{ command }}
    - target: /srv/salt/venv/bin/{{ command }}
{% endfor %}

Ensure supervisor is installed:
  pkg.installed:
    - name: supervisor

Ensure supervisor is running:
  service.running:
    - name: supervisor
    - enable: True

Conditionally reload supervisor:
  cmd.wait:
    - name: supervisorctl update

Ensure salt-minion configuration exists:
  file.managed:
    - name: /etc/salt/minion.d/minion
    - source: salt://common/salt/minion
    - template: jinja
    - makedirs: True
    - listen_in:
      - cmd: Restart salt-minion

Ensure salt-minion supervisor configuration exists:
  file.managed:
    - name: /etc/supervisor/conf.d/salt-minion.conf
    - source: salt://common/supervisor/salt-minion.conf
    - listen_in:
      - cmd: Conditionally reload supervisor

Restart salt-minion:
  cmd.wait:
    - name: supervisorctl restart salt-minion
