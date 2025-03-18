# Base image
FROM ubuntu:24.04

# Switch to the non-root user
USER runner

# Set the working directory
WORKDIR /opt/docker-actions-runner

# Add /home/runner/.local/bin to the PATH environment variable.
ENV PATH="/home/runner/.local/bin:$PATH"

# Define the entry point
ENTRYPOINT ["/opt/docker-actions-runner/start.sh"]
