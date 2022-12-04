from pyinfra.operations import files, server, apt

CONNECT_TIMEOUT = 1
FAIL_PERCENT = 0

server.user(
    name="Add user",
    user="pyinfra",
    present=True,
    ensure_home=False,
    add_deploy_dir=False,
    unique=True,
    _sudo=True,
)

files.file(
    name="Add file",
    path="/home/test/pyinfra-add.txt",
    mode="777",
    user="pyinfra",
    group="pyinfra",
    touch=True,
    create_remote_dir=False,
    _sudo=True,
)

files.put(
    name="Upload file",
    src="./pyinfra-upload.txt",
    dest="/home/test",
)
