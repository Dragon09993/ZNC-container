#!/bin/bash

set -e

ZNC_CONFIG_DIR="/opt/znc/.znc"
ZNC_CERT_FILE="$ZNC_CONFIG_DIR/znc.pem"
ZNC_CONFIG_FILE="$ZNC_CONFIG_DIR/configs/znc.conf"

echo "Starting ZNC setup..."

# Generate SSL certificate if needed
if [ ! -f "$ZNC_CERT_FILE" ]; then
    echo "Generating SSL certificate..."
    openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
        -keyout "$ZNC_CERT_FILE" \
        -out "$ZNC_CERT_FILE" \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=znc-bouncer"
    chmod 600 "$ZNC_CERT_FILE"
    echo "SSL certificate generated"
fi

# Create minimal configuration if it doesn't exist
if [ ! -f "$ZNC_CONFIG_FILE" ]; then
    echo "Creating initial ZNC configuration..."
    mkdir -p "$ZNC_CONFIG_DIR/configs"
    echo "INFO: No existing configuration found, creating new setup..."
    
    # Get environment variables with defaults
    ZNC_USER="${ZNC_USER:-admin}"
    ZNC_PASSWORD="${ZNC_PASSWORD:-changeme}"
    ZNC_IRC_NICK="${ZNC_IRC_NICK:-znc-user}"
    ZNC_IRC_SERVER="${ZNC_IRC_SERVER:-irc.libera.chat}"
    ZNC_IRC_PORT="${ZNC_IRC_PORT:-6697}"
    ZNC_IRC_SSL="${ZNC_IRC_SSL:-true}"
    
    # Determine SSL prefix for server
    if [ "$ZNC_IRC_SSL" = "true" ]; then
        IRC_SERVER_LINE="Server = ${ZNC_IRC_SERVER} +${ZNC_IRC_PORT}"
    else
        IRC_SERVER_LINE="Server = ${ZNC_IRC_SERVER} ${ZNC_IRC_PORT}"
    fi
    
    cat > "$ZNC_CONFIG_FILE" << EOF
Version = 1.9
AnonIPLimit = 10
ConnectDelay = 5
MaxBufferSize = 500
PidFile = /opt/znc/.znc/znc.pid
ServerThrottle = 30
SSLCertFile = /opt/znc/.znc/znc.pem

LoadModule = webadmin

<Listener web>
    AllowIRC = false
    AllowWeb = true
    IPv4 = true
    IPv6 = true
    Port = 8080
    SSL = false
    URIPrefix = /
</Listener>

<Listener irc>
    AllowIRC = true
    AllowWeb = false
    IPv4 = true
    IPv6 = true
    Port = 6667
    SSL = false
</Listener>

<Listener ssl>
    AllowIRC = true
    AllowWeb = false
    IPv4 = true
    IPv6 = true
    Port = 6697
    SSL = true
</Listener>

<User ${ZNC_USER}>
    Admin = true
    Nick = ${ZNC_IRC_NICK}
    AltNick = ${ZNC_IRC_NICK}_
    Ident = ${ZNC_IRC_NICK}
    RealName = ZNC User
    LoadModule = chansaver
    LoadModule = controlpanel
    LoadModule = log
    LoadModule = buffextras
    LoadModule = savebuff
    Pass = plain#${ZNC_PASSWORD}#
    Allow = 10.0.0.*

    <Network local>
        LoadModule = simple_away
        ${IRC_SERVER_LINE}
        
        <Chan #znc>
        </Chan>
    </Network>
</User>
EOF

    echo "Initial ZNC configuration created with user '${ZNC_USER}'"
    echo "You can access the web interface at http://localhost:8085"
    echo "Login with username: ${ZNC_USER} and the password you set in .env"
    
    # Fix ownership of created files
    chown -R znc:znc "$ZNC_CONFIG_DIR"
    echo "Configuration created successfully!"
else
    echo "INFO: Existing ZNC configuration found, using persistent data..."
fi

echo "Starting ZNC..."

# Switch to znc user and start ZNC
exec gosu znc "$@"