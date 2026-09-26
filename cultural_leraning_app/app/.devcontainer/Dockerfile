FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install essential dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y --no-install-recommends \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-17-jdk \
    wget \
     && rm -rf /var/lib/apt/lists/*

# Set up non-root user (vscode)
USER vscode
WORKDIR /home/vscode

# Download and install Flutter SDK (Stable channel)
ENV FLUTTER_HOME="/home/vscode/flutter"
RUN git clone https://github.com/flutter/flutter.git -b stable $FLUTTER_HOME

# Add Flutter to path
ENV PATH="$FLUTTER_HOME/bin:$PATH"

# Enable web support and pre-cache binaries
RUN flutter config --enable-web
RUN flutter precache --web

# Expose default web server port for testing
EXPOSE 8080