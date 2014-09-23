base:
  '*':
    # This for loop will obviously be a problem if you're using more than one
    # file root and you have a local.sls in it. It would be good to find a
    # better way to handle this.
    {% for root in opts['pillar_roots']['base'] -%}
    {% set local_sls = '{0}/local.sls'.format(root) -%}
    {% if salt['file.file_exists'](local_sls) %}
    - local
    {% endif %}
    {% endfor -%}
    - example
