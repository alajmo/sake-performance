#!/usr/bin/env python3.10

import json
import os

n_hosts = os.environ.get('ANSIBLE_TEST_HOSTS', '1')
n_hosts = int(n_hosts)


inventory = {
    'all': {
        'hosts': [
            'host_{0}'.format(n)
            for n in range(0, n_hosts)
        ],
        'vars': {
            'ansible_ssh_user': 'test',
            'ansible_ssh_private_key_file': '../id_ed25519_pem_no',
            'ansible_python_interpreter': '/usr/bin/python3.10',
        },
    },
    '_meta': {
        'hostvars': {
            'host_{0}'.format(n): {
                'ansible_ssh_port': 10000 + n,
                'ansible_ssh_host': '0.0.0.0',
            }
            for n in range(0, n_hosts)
        },
    },
}


# Print the JSON which Ansible reads
print(json.dumps(inventory))
