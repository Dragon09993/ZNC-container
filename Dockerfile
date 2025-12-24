ARG BASE_IMAGE=ubuntu:22.04
FROM ${BASE_IMAGE}

# Install dependencies and ZNC
# This section handles both Ubuntu (apt) and Alpine (apk) package managers
RUN if command -v apt-get > /dev/null 2>&1; then \
        # Ubuntu/Debian installation
        apt-get update && \
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
        && rm -rf /var/lib/apt/lists/*; \
    elif command -v apk > /dev/null 2>&1; then \
        # Alpine installation
        apk add --no-cache \
        znc \
        znc-extra \
        znc-modpython \
        znc-modperl \
        znc-modtcl \
        openssl \
        ca-certificates \
        curl \
        su-exec; \
    else \
        echo "Unsupported base image" && exit 1; \
    fi

# Create ZNC user and directories (cross-platform)
RUN if command -v useradd > /dev/null 2>&1; then \
        # Ubuntu/Debian user creation
        useradd -r -s /bin/false -d /opt/znc znc; \
    elif command -v adduser > /dev/null 2>&1; then \
        # Alpine user creation
        adduser -D -s /sbin/nologin -h /opt/znc znc; \
    else \
        echo "Unsupported user creation method" && exit 1; \
    fi && \
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
    CMD pidof znc || exit 1

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["znc", "--foreground"]