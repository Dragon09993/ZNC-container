FROM ubuntu:22.04

# Install dependencies and ZNC
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    znc \
    znc-dev \
    znc-python \
    znc-perl \
    znc-tcl \
    openssl \
    ca-certificates \
    curl \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# Create ZNC user and directories
RUN useradd -r -s /bin/false -d /opt/znc znc && \
    mkdir -p /opt/znc/.znc && \
    chown -R znc:znc /opt/znc

# Create directory for SSL certificates
RUN mkdir -p /opt/znc/.znc/ssl && \
    chown -R znc:znc /opt/znc/.znc/ssl

# Copy configuration template
COPY --chown=znc:znc config/znc.conf.template /tmp/znc.conf.template

# Generate SSL certificate if it doesn't exist
COPY scripts/generate-ssl.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/generate-ssl.sh

# Copy entrypoint script
COPY scripts/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

# Stay as root for initial setup, switch to znc user in entrypoint
WORKDIR /opt/znc

# Expose ports (6697 for SSL, 6667 for non-SSL, 8080 for web interface)
EXPOSE 6667 6697 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD netstat -an | grep LISTEN | grep :6697 || exit 1

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["znc", "--foreground"]