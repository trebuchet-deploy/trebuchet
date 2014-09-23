Ensure /srv/ricochet directory exists:
  file.directory:
    - name: /srv/ricochet

Ensure ricochet venv is managed:
  virtualenv.managed:
    - name: /srv/ricochet/venv
    - requirements: salt://ricochet/requirements.txt
    - listen_in:
      - cmd: Restart ricochet

Ensure ricochet supervisor configuration exists:
  file.managed:
    - name: /etc/supervisor/conf.d/ricochet.conf
    - source: salt://common/supervisor/ricochet.conf
    - listen_in:
      - cmd: Conditionally reload supervisor

Ensure trigger venv is managed:
  virtualenv.managed:
    - name: /srv/trigger/venv
    - requirements: salt://ricochet/trigger-requirements.txt

Restart ricochet:
  cmd.wait:
    - name: supervisorctl restart ricochet
