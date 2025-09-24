FROM ubuntu:22.04 AS dumbkv-base

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends build-essential git && rm -rf /var/lib/apt/lists/*

RUN uv python install 3.12

# Copying lockfile and project.toml first to avoid re-installing the dependencies
COPY pyproject.toml uv.lock .
RUN uv sync
# Copying the rest of the application
COPY . /app

# Build for the main stage where we run the application
FROM dumbkv-base AS dumbkv-main
EXPOSE 8000
ENTRYPOINT ["uv", "run", "uvicorn", "main:api", "--host", "0.0.0.0", "--port", "8000"]
CMD ["--log-config", "logging.yaml"]

# Build for the test stage where we run the tests
FROM dumbkv-base AS dumbkv-test
ENTRYPOINT ["uv", "run", "pytest"]
CMD ["-v", "--database-location", "postgres://postgres:postgres@localhost/postgres"]