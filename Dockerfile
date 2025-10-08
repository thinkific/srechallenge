FROM ubuntu:24.10

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends build-essential git && rm -rf /var/lib/apt/lists/*

RUN uv python install 3.12

# Copy dependency files first for better Docker layer caching
COPY pyproject.toml uv.lock ./

# Install Python dependencies without dev packages
RUN uv sync --frozen --no-dev

# Copy the rest of the application code
COPY . .

# Expose port 8000 for the API
EXPOSE 8000

# Run the application using uvicorn
CMD ["uv", "run", "uvicorn", "main:api", "--host", "0.0.0.0", "--port", "8000"]

# Done
# TODO: Install the python packages and run uvicorn