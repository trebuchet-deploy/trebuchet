example_profile:
  key: <your_aws_access_key>
  keyid: <your_aws_secret_key>
  key_name: <your_aws_ssh_key>
  region: <your_preferred_ec2_region>
  vpc_id: <your_vpc_id>
  vpc_subnets:
    - <a_vpc_subnet-id>
    - <a_vpc_subnet-id>
    - <a_vpc_subnet-id>

# Example: trebuchet-deploy.com
domain: <your_domain>

# present/absent. If set to present, a highstate will create all aws resources.
# If set to absent, a highstate will delete all aws resources.
orchestration_status: present
