{% for command in ['salt', 'salt-api', 'salt-cloud', 'salt-cp', 'salt-key',
                   'salt-master', 'salt-run', 'salt-ssh', 'salt-syndic', 'salt-unity'] %}
Ensure {{ command }} link exists:
  file.symlink:
    - name: /usr/local/bin/{{ command }}
    - target: /srv/salt/venv/bin/{{ command }}
{% endfor %}

Ensure salt-master configuration exists:
  file.managed:
    - name: /etc/salt/master.d/master
    - source: salt://saltmaster/config/master
    - makedirs: True
    - listen_in:
      - cmd: Restart salt-master

Ensure salt-master auto_accept configuration exists:
  file.managed:
    - name: /etc/salt/auto_accept.conf
    - source: salt://saltmaster/config/auto_accept.conf
    - template: jinja

Ensure salt-master supervisor configuration exists:
  file.managed:
    - name: /etc/supervisor/conf.d/salt-master.conf
    - source: salt://common/supervisor/salt-master.conf
    - listen_in:
      - cmd: Conditionally reload supervisor

Restart salt-master:
  cmd.wait:
    - name: supervisorctl restart salt-master
