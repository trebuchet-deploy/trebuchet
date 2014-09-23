# Launch your own trebuchet example in AWS

This example is meant to launch a fully operational trebuchet infrastructure
with trebuchet, ricochet, and a deployment server. The infrastructure will fully
bootstrap itself with salt and trebuchet and updates to the infrastructure will
also be managed through trebuchet as well.

## Work in progress

This is a work in progress. It only works for specific configurations of
trebuchet and has hardcoded resources.

## WARNING

This example uses some hardcoded resource names in AWS, please pay close
attention to what the orchestration code is doing or you may reconfigure or
delete infrastructure you're using in your account!

## Orchestration

The orchestration is handled by salt states and is configured through pillars.
The orchestration code uses a pillar/local.sls pillar file, which is ignored by
git. It's only used by orchestration, so don't add anything here that's needed
by configuration management.

Here's the format of the local.sls file:

_pillar/local.sls_
```yaml
example_profile:
  key: <your_aws_access_key>
  key_id: <your_aws_secret_key>
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
```

The states can be run from your local system, via a virtual environment (this
example uses virtualenvwrapper):

```bash
mkvirtualenv trebuchet
workon trebuchet
pip install -r ../requirements.txt
salt-call -c .orchestration state.highstate
```
