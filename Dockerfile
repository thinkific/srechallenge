# Used stable LTS (24.04). 24.10 repos are gone.
FROM ubuntu:24.04

# install curl and basic build tools (uv needs curl)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates build-essential git libpq-dev \
    && rm -rf /var/lib/apt/lists/*

#RUN curl -LsSf https://astral.sh/uv/install.sh | sh
#uv binaries
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ENV PATH="/root/.local/bin:${PATH}"

WORKDIR /app

#install python 3.12 and deps
COPY pyproject.toml uv.lock ./
COPY .. .
RUN uv python install 3.12 && uv sync --frozen --no-dev 

ENV DATABASE_TYPE=sqlite \
    DATABASE_LOCATION=/dumbkvstore/dumbkv.db

# sqlite data dir
RUN mkdir -p /dumbkvstore

EXPOSE 8000
CMD ["uv","run","uvicorn","main:api","--host","0.0.0.0","--port","8000"]
