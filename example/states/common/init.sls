{% for name, user in pillar['users'].items() %}
Ensure human user {{ name }} exist:
  user.present:
    - name: {{ name }}
    - uid: {{ user.id }}
    - gid_from_name: True
    - shell: /bin/bash
    - createhome: True
    - password: '*'
    - fullname: {{ user.full_name }}
    {% if user.get('disabled', False) %}
    - expire: 1
    {% endif %}

{% if 'ssh_key' in user and not user.get('disabled', False) %}
Ensure authorized_keys for {{ name }} is present:
  file.managed:
    - name: /home/{{ name }}/.ssh/authorized_keys
    - contents_pillar: users:{{ name }}:ssh_key
    - user: {{ name }}
    - group: {{ name }}
    - mode: 600
    - dir_mode: 700
    - makedirs: True
{% else %}
Ensure authorized_keys for {{ name }} is absent:
  file.absent:
    - name: /home/{{ name }}/.ssh/authorized_keys
{% endif %}

{% if 'ssh_private_key' in user %}
Ensure ssh private key for {{ name }} is present:
  file.managed:
    - name: /home/{{ name }}/.ssh/id_rsa
    - contents_pillar: users:{{ name }}:ssh_private_key
    - user: {{ name }}
    - group: {{ name }}
    - mode: 600
    - dir_mode: 700
    - makedirs: True
{% else %}
Ensure ssh private key for {{ name }} is absent:
  file.absent:
    - name: /home/{{ name }}/.ssh/id_rsa
{% endif %}

Ensure mail alias for {{ name }} is set:
  alias.present:
    - name: {{ name }}
    - target: {{ user.email }}
{% endfor %}

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
    - name: /etc/salt/minion
    - source: salt://common/salt/minion
    - template: jinja
    - makedirs: True
    - listen_in:
      - cmd: Restart salt-minion

Ensure salt-minion node-specific configuration exists:
  file.managed:
    - name: /etc/salt/minion.d/minion-specific.conf
    - source: salt://common/salt/minion-specific.conf
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
