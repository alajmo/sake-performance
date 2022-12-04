from pyinfra.operations import server

CONNECT_TIMEOUT = 1
FAIL_PERCENT = 0

server.shell(
    name="ping",
    commands=["echo pong"],
)
