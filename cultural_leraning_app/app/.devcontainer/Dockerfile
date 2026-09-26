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

# Add Flutter to PATH and create a global system symlink so it's always found
USER root
RUN ln -s /home/vscode/flutter/bin/flutter /usr/local/bin/flutter
RUN ln -s /home/vscode/flutter/bin/dart /usr/local/bin/dart
USER vscode

# Enable web support and pre-cache binaries
RUN flutter config --enable-web
RUN flutter precache --web

EXPOSE 8080