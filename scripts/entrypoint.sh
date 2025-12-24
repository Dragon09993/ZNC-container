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
    
    # Generate a simple password hash (using sha256)
    PASSWORD_HASH="sha256#e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855#YWRtaW4=#"
    
    cat > "$ZNC_CONFIG_FILE" << 'EOF'
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

<User admin>
    Admin = true
    Nick = znc
    AltNick = znc_
    Ident = znc
    RealName = ZNC User
    LoadModule = chansaver
    LoadModule = controlpanel
    LoadModule = log
    LoadModule = buffextras
    LoadModule = savebuff
    Pass = plain#znc
    Allow = 192.168.1.95

    <Network freenode>
        LoadModule = simple_away
        Server = chat.freenode.net +6697
        
        <Chan #znc>
        </Chan>
    </Network>
</User>
EOF

    echo "Initial ZNC configuration created with user 'admin' and password 'password'"
    echo "You can change this via the web interface at http://localhost:8085"
    
    # Fix ownership of created files
    chown -R znc:znc "$ZNC_CONFIG_DIR"
    echo "Configuration created successfully!"
else
    echo "INFO: Existing ZNC configuration found, using persistent data..."
fi

echo "Starting ZNC..."

# Switch to znc user and start ZNC
exec gosu znc "$@"
