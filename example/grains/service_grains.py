'''
Set service_*, and region grains based on the hostname or ec2 Name tag.
'''
import re
import salt.utils.network
import boto
import boto.utils
import boto.ec2
import time
import logging

log = logging.getLogger(__name__)


def _get_instance_info():
    identity = boto.utils.get_instance_identity()['document']
    return (identity['instanceId'], identity['region'])


def _on_ec2():
    m = boto.utils.get_instance_metadata(timeout=0.5, num_retries=3)
    return len(m.keys()) > 0


def _get_name_from_tags():
    (instance_id, region) = _get_instance_info()

    # Connect to EC2 and parse the Roles tags for this instance
    conn = boto.ec2.connect_to_region(region)

    tags = {}
    try:
        for i in range(120):
            _tags = conn.get_all_tags(filters={'resource-type': 'instance',
                                               'resource-id': instance_id})
            for tag in _tags:
                tags[tag.name] = tag.value
            if 'aws:autoscaling:groupName' in tags:
                break
            time.sleep(3)
    except IndexError, e:
        log.error("Couldn't retrieve instance information: %s", e)
        return ''

    cluster_name_arr = tags['aws:autoscaling:groupName'].split('-')
    # The returned name should always be in form:
    #   service_name-service_instance-region-service_node
    # The cluster name is the first 3, service_node is either the instanceid or
    # canary, based on whether the 4th token is canary. Any other token is
    # ignored, so that we can create temporary clusters, while keeing the
    # hostnames stable.
    cluster_name = '-'.join(cluster_name_arr[0:3])
    if len(cluster_name_arr) > 3 and cluster_name_arr[3] == 'canary':
        # This is a canary autoscaling group.
        # example: saltmaster-testing-useast1-canary
        return '{0}-canary'.format(cluster_name)
    else:
        return '{0}-{1}'.format(cluster_name, instance_id[2:])


def parse_host():
    # Get the grains from the hostname if it's set and matches our convention.
    # Example: saltmaster-testing-useast1-909nui9h.trebuchet-deploy.com
    name_regex = '^(\w+)-(\w+)-(\w+)-(\w+)($|\.{1})'
    match = re.match(name_regex, salt.utils.network.get_fqhostname())
    if not match:
        # If the hostname wasn't set to our convention, try to fetch the name
        # from the EC2 Name tag.
        if _on_ec2():
            # Example: saltmaster-testing-useast1-03e83d29
            name_regex = '^(\w+)-(\w+)-(\w+)-(\w+)'
            match = re.match(name_regex, _get_name_from_tags())
        else:
            return {}
    service_name = match.group(1)
    service_instance = match.group(2)
    region = match.group(3)
    service_node = match.group(4)
    service_group = '{0}-{1}'.format(service_name, service_instance, region)
    cluster_name = '{0}-{1}'.format(service_group, region)
    return {
        'service_name': service_name,
        'service_instance': service_instance,
        'region': region,
        'service_node': service_node,
        'service_group': service_group,
        'cluster_name': cluster_name
    }
