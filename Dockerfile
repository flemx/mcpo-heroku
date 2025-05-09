FROM python:3.12-slim-bookworm

# Install uv (from official binary), nodejs, npm, and git
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js and npm via NodeSource 
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Deno
RUN curl -fsSL https://deno.land/x/install/install.sh | sh
ENV DENO_INSTALL="/root/.deno"
ENV PATH="$DENO_INSTALL/bin:$PATH"

# Confirm installations
RUN node -v && npm -v && deno --version && uv --version

# Copy mcpo source code without virtual environments
COPY . /app
WORKDIR /app

# Remove any possibly copied virtual environments
RUN find /app -type d -name ".venv" -exec rm -rf {} +

# Create virtual environment
ENV VIRTUAL_ENV=/app/.venv
RUN uv venv "$VIRTUAL_ENV"
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install mcpo
RUN uv pip install . && rm -rf ~/.cache

# Expose port
EXPOSE 8000

# No fixed entrypoint - this allows Heroku to set the command
# Default command shows help
CMD ["mcpo", "--help"]