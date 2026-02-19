FROM mcr.microsoft.com/devcontainers/base:ubuntu

ARG DEBIAN_FRONTEND=noninteractive

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
      curl unzip git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# .NET SDK 10.0.102 LTS
RUN curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin \
      --version 10.0.102 \
      --install-dir /usr/share/dotnet \
    && ln -sf /usr/share/dotnet/dotnet /usr/local/bin/dotnet
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH="${PATH}:${DOTNET_ROOT}:${DOTNET_ROOT}/tools"

# .NET Aspire workload + Avalonia templates
RUN dotnet workload install aspire \
    && dotnet new install Avalonia.Templates

# Bun
RUN curl -fsSL https://bun.sh/install | bash \
    && ln -sf /root/.bun/bin/bun /usr/local/bin/bun

# uv (Astral Python package manager)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && ln -sf /root/.local/bin/uv /usr/local/bin/uv \
    && ln -sf /root/.local/bin/uvx /usr/local/bin/uvx

# opencode CLI
RUN curl -fsSL https://opencode.ai/install | bash

# cp AGENTS.md to the workspace root for opencode CLI's use
COPY AGENTS.md /workspace/AGENTS.md


