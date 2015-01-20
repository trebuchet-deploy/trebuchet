{% set hostname = '{0}-{1}'.format(grains['cluster_name'], grains['service_node']) %}
# If the environment variable DOMAIN is set, use that for the domain.
# Otherwise, use the domain grain.
{% set domain = salt['environ.get']('DOMAIN', grains['domain']) %}
{% set fqdn = '{0}.{1}'.format(hostname, domain) %}

Ensure hostname is set in /etc/hosts:
  host.present:
    - ip:
      - 127.0.1.1
    - names:
      - {{ fqdn }}
      - {{ hostname }}

Ensure /etc/hostname is set:
  file.managed:
    - name: /etc/hostname
    - contents: {{ hostname }}

Ensure hostname is set:
  cmd.run:
    - name: hostname {{ hostname }}
    - unless: hostname | grep {{ hostname }}
    - reload_modules: True

{% include 'common/init.sls' %}
