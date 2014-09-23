Ensure salt-master configuration exists:
  file.managed:
    - name: /etc/salt/master.d/master.conf
    - source: salt://saltmaster/config/master.conf
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
