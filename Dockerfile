FROM ubuntu:24.04

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends build-essential git && rm -rf /var/lib/apt/lists/*

RUN uv python install 3.12

# Copy dependency files first (for better layer caching)
COPY pyproject.toml uv.lock ./

# Install Python packages
RUN uv sync --frozen --no-cache

# Copy the rest of the application code
COPY . .

# Expose the application port
EXPOSE 8000

# Run uvicorn server
CMD ["uv", "run", "uvicorn", "main:api", "--host", "0.0.0.0", "--port", "8000", "--log-config", "logging.yaml"]
# TODO: Install the python packages and run uvicorn# Built with GitHub Actions

# Built with GitHub Actions"
