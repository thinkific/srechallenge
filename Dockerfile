FROM ubuntu:24.10

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends build-essential git && rm -rf /var/lib/apt/lists/*

RUN uv python install 3.12

COPY . /app

RUN uv sync

ENV HOST="0.0.0.0" PORT="8000" LOG_CONFIG="logging.yaml"
CMD uv run uvicorn main:api --host $HOST --port $PORT --log-config $LOG_CONFIG
