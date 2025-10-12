FROM ubuntu:24.10

#RUN curl -LsSf https://astral.sh/uv/install.sh | sh
#uv binaries
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

#adding libpq-dev so Postgres wheels can build when needed
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    build-essential git ca-certificates libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.12 
RUN uv python install 3.12

# --- install project dependencies (from lock/pyproject) ---
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --python 3.12

# --- app source ---
COPY . .

# default to SQLite; can override to Postgres via env at runtime
ENV DATABASE_TYPE=sqlite \
    DATABASE_LOCATION=/dumbkvstore/dumbkv.db

# sqlite data dir
RUN mkdir -p /dumbkvstore

EXPOSE 8000

# run the API
CMD ["uv", "run", "uvicorn", "main:api", "--host", "0.0.0.0", "--port", "8000", "--log-config", "logging.yaml"]
