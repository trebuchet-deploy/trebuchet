Ensure base security group exists:
  boto_secgroup.{{ pillar['orchestration_status'] }}:
    - name: base
    - description: base
    - rules:
        - ip_protocol: tcp
          from_port: 4505
          to_port: 4506
          source_group_name: base
        # You probably want to limit ssh to a bastion host in production,
        # rather than having it open to the world, like this.
        - ip_protocol: tcp
          from_port: 22
          to_port: 22
          cidr_ip: 0.0.0.0/0
    # If using a vpc, specify the ID for the group
    {% if salt['pillar.get']('example_profile.vpc_id', '') -%}
    - vpc_id: {{ salt['pillar.get']('example_profile.vpc_id') }}
    {% endif -%}
    - profile: example_profile

Ensure elb security group exists:
  boto_secgroup.{{ pillar['orchestration_status'] }}:
    - name: elb
    - description: elb
    - rules:
        - ip_protocol: tcp
          from_port: 80
          to_port: 80
          cidr_ip: 0.0.0.0/0
        - ip_protocol: tcp
          from_port: 443
          to_port: 443
          cidr_ip: 0.0.0.0/0
    # If using a vpc, specify the ID for the group
    {% if salt['pillar.get']('example_profile.vpc_id', '') -%}
    - vpc_id: {{ salt['pillar.get']('example_profile.vpc_id') }}
    {% endif -%}
    - profile: example_profile
