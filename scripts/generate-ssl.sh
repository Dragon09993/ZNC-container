#!/bin/bash

# Generate SSL certificate for ZNC
SSL_DIR="/opt/znc/.znc/ssl"
CERT_FILE="/opt/znc/.znc/znc.pem"

echo "Generating SSL certificate for ZNC..."

mkdir -p "$SSL_DIR"

openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -keyout "$CERT_FILE" \
    -out "$CERT_FILE" \
    -subj "/C=US/ST=State/L=City/O=ZNC/CN=znc-bouncer"

chmod 600 "$CERT_FILE"
chown znc:znc "$CERT_FILE"

echo "SSL certificate generated successfully at $CERT_FILE"