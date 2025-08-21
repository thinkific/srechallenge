# https://just.systems

_default:
    @just --list

HOST := '0.0.0.0'
PORT := '8000'
LOG_CONFIG := 'logging.yaml'

run:
    uv run uvicorn main:api --host {{HOST}} --port {{PORT}} --log-config {{LOG_CONFIG}}

[group('docker')]
build:
    docker build -t kbluescode/dumbkv .

[group('docker')]
run-image:
    docker run --rm -it -p {{PORT}}:{{PORT}} kbluescode/dumbkv

[group('testing')]
test:
    uv run python -m pytest

DATABASE_URI := 'postgres://postgres:postgres@127.0.0.1/postgres'

[group('testing')]
test-pg:
    uv run python -m pytest -v --database-location={{DATABASE_URI}}
