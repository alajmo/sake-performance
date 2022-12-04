import os


n_hosts = os.environ.get('PYINFRA_TEST_HOSTS', '1')
n_hosts = int(n_hosts)
hosts = [
    ("host_{0}".format(i), { 'ssh_hostname': '0.0.0.0', 'ssh_port': str(10000 + i), 'ssh_user': 'test', 'ssh_key': '../id_ed25519_pem_no' }) for i in range(n_hosts)
]
