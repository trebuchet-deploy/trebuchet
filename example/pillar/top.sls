{% for root in opts['pillar_roots']['base'] -%}
{% set local_sls = '{0}/{1}.sls'.format(root, 'local') -%}
{% set local_sls_exists = salt['file.file_exists'](local_sls) -%}
{% endfor -%}
{% if local_sls_exists -%}
base:
  '*':
    - local
{% endif -%}
