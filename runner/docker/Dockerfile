# Base image
FROM ubuntu:24.04

# Set noninteractive mode for APT
ARG DEBIAN_FRONTEND=noninteractive
# Automatically provided by Docker buildx
ARG TARGETPLATFORM

RUN apt-get update && apt-get install -y curl ca-certificates openssl

# Add user and setup Docker
RUN useradd -m runner && \
    curl -fsSL https://get.docker.com | sh && \
    usermod -aG docker runner

# Switch to the non-root user
USER runner

# Set the working directory
WORKDIR /opt/docker-actions-runner

# Add /home/runner/.local/bin to the PATH environment variable.
ENV PATH="/home/runner/.local/bin:$PATH"

# Define the entry point
ENTRYPOINT ["/opt/docker-actions-runner/start.sh"]
