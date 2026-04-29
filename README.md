# ZNC Docker Setup

A complete Docker-based ZNC (IRC bouncer) setup with SSL support, web interface, and management scripts.

## Features

-  **Docker-based**: Easy deployment and management
-  **SSL Support**: Automatic SSL certificate generation
-  **Web Interface**: ZNC web admin on port 8080
-  **Persistent Storage**: Configuration and logs preserved across restarts
-  **Management Scripts**: Easy backup, restore, and maintenance
-  **Pre-configured**: Ready-to-use templates and sensible defaults

## Quick Start

### 1. Clone and Setup

```bash
git clone <your-repo> znc-docker
cd znc-docker

# Copy and edit environment configuration
cp .env.example .env
nano .env  # Edit with your settings

# IMPORTANT: Never commit .env to git!
```

### 2. Configure Environment

Edit `.env` file with your settings:

```bash
# ZNC Admin User Configuration
ZNC_USER=admin
ZNC_PASSWORD=your_secure_password_here

# IRC Configuration
ZNC_IRC_NICK=your_nick
ZNC_IRC_SERVER=irc.libera.chat
ZNC_IRC_PORT=6697
ZNC_IRC_SSL=true

# User/Group IDs (match your host user)
PUID=1000
PGID=1000
```

### 3. Start ZNC

```bash
# Build and start ZNC
./scripts/znc-manager.sh build
./scripts/znc-manager.sh start
```

### 4. Access ZNC

- **Web Interface**: http://localhost:8085
- **IRC SSL Port**: 6697
- **IRC Non-SSL Port**: 6667

## Management Commands

Use the included management script for easy operations:

```bash
# Build container
./scripts/znc-manager.sh build

# Start/Stop/Restart ZNC
./scripts/znc-manager.sh start
./scripts/znc-manager.sh stop
./scripts/znc-manager.sh restart

# View status and logs
./scripts/znc-manager.sh status
./scripts/znc-manager.sh logs

# Backup and restore
./scripts/znc-manager.sh backup
./scripts/znc-manager.sh restore /path/to/backup.tar.gz

# Open shell in container
./scripts/znc-manager.sh shell
```

## Configuration

### Initial Setup

1. **First Run**: The container will automatically generate SSL certificates and create initial configuration
2. **Web Access**: Navigate to http://localhost:8085 and log in with credentials from `.env`
3. **Add Networks**: Use the web interface to add IRC networks and channels
4. **Configure Modules**: Enable desired ZNC modules through the web interface

### IRC Client Configuration

Configure your IRC client to connect through ZNC:

- **Server**: `your-server-ip` or `localhost`
- **Port**: `6697` (SSL) or `6667` (non-SSL)
- **Username**: `username/network` (e.g., `admin/local`)
- **Password**: Use `znc` (simple password for local network)
- **SSL**: Enable if using port 6697

**Note**: Use the simple password `znc` for connections from the 10.0.0.* subnet.

#### Alternative: Certificate-based Authentication (No Password Required)

You can configure ZNC to use SSL client certificates instead of passwords:

1. Generate a client certificate:
   ```bash
   openssl req -new -x509 -days 365 -nodes -out client.pem -keyout client.pem
   ```

2. In ZNC web interface, go to User Settings → Authentication
3. Enable "Require SSL" and upload your client certificate
4. Configure your IRC client to use the client certificate
5. Connect without a password - authentication is handled by the certificate

### Popular IRC Networks

Pre-configured servers you can add:

- **Libera.Chat**: `irc.libera.chat:6697` (SSL)
- **OFTC**: `irc.oftc.net:6697` (SSL)
- **EFNet**: `irc.efnet.org:6697` (SSL)

## Directory Structure

```
znc-docker/
├── Dockerfile              # ZNC container definition
├── docker-compose.yml      # Docker Compose configuration
├── .env.example            # Environment variables template
├── config/
│   └── znc.conf.template   # ZNC configuration template
├── scripts/
│   ├── entrypoint.sh       # Container startup script
│   ├── generate-ssl.sh     # SSL certificate generator
│   └── znc-manager.sh      # Management utility
└── README.md              # This file
```

## Volumes and Data

- **znc_data**: Main ZNC data volume (configurations, logs, etc.) - **PERSISTENT**
- **./logs**: Local ZNC logs directory (mounted from container)

### Data Persistence
Your ZNC configuration, users, and settings are stored in the `znc_data` Docker volume and will persist across container restarts and rebuilds. Only a complete volume removal will delete your data.

### Check Persistent Data
```bash
# Check if your data volume exists
docker volume ls | grep znc

# View volume contents
docker run --rm -v znc_znc_data:/data alpine ls -la /data

# Backup your configuration
./scripts/znc-manager.sh backup
```

## Security Considerations

1. **Change Default Password**: Always change the default password in `.env`
2. **Never Commit .env**: The `.env` file contains sensitive credentials and is git-ignored
3. **SSL Certificates**: Use proper SSL certificates for production
4. **Firewall**: Ensure only necessary ports are exposed
5. **Backups**: Regularly backup your configuration
6. **Updates**: Keep ZNC and base images updated
7. **Network Isolation**: Use the 10.0.0.* subnet restriction or similar for your network

See [SECURITY.md](SECURITY.md) for detailed security guidelines.

## Useful ZNC Commands

Send these commands in your IRC client:

```
/msg *status help              # Get help
/msg *status listmods          # List available modules
/msg *status loadmod <module>  # Load a module
/msg *status listchans         # List channels
/msg *status disconnect        # Disconnect from IRC
/msg *status connect          # Reconnect to IRC
```

## Popular ZNC Modules

- **savebuff**: Save and replay buffer contents (message history)
- **buffextras**: Enhanced buffer playback with timestamps  
- **log**: Log IRC conversations to files (Essential for away logging)
- **autoattach**: Automatically attach to channels
- **adminlog**: Log administrative actions
- **clientnotify**: Get notified when clients connect/disconnect
- **perform**: Execute commands on connect
- **sasl**: SASL authentication support

## Away Message Storage (Buffering)

ZNC automatically stores messages while you're disconnected, but you need to configure buffering:

### Enable Logging Module:
1. **Via Web Interface**: http://localhost:8085 → User Settings → Modules → Check "log"
2. **Via IRC**: `/msg *status loadmod log`

### Configure Buffer Settings:
- **Via Web**: User Settings → Advanced → Buffer Size (set to 500-1000)
- **Via IRC**: `/msg *status setbuffer 1000`

### Enable Channel Logging:
- **Via IRC**: `/msg *log help` (shows log commands)
- **Via IRC**: `/msg *log set #channelname 1` (enable for specific channel)

### Buffer and Message Replay:
ZNC automatically stores messages in buffers and replays them when you reconnect:

- **buffextras**: Provides enhanced timestamps and formatting
- **savebuff**: Saves buffer contents across restarts
- **Built-in buffering**: ZNC automatically replays missed messages

### Buffer Commands:
- **Via IRC**: `/msg *status help` (show status commands)
- **Via IRC**: `/msg *status replay` (replay buffer contents)
- **Via IRC**: `/msg *status clearbuffer` (clear message buffer)
- **Via IRC**: `/msg *status setbuffer 500` (set buffer size)

## Troubleshooting

### Container Won't Start

```bash
# Check logs
./scripts/znc-manager.sh logs

# Check container status
docker-compose ps

# Rebuild container
./scripts/znc-manager.sh build
```

### Can't Connect to Web Interface

1. Check if container is running: `./scripts/znc-manager.sh status`
2. Verify port 8085 is not blocked by firewall
3. Check logs for errors: `./scripts/znc-manager.sh logs`

### IRC Client Connection Issues

1. Verify ZNC is running and listening on IRC ports
2. Check username format: `username/network`
3. Ensure password matches ZNC configuration
4. For SSL connections, verify certificates are valid

### Reset Configuration

```bash
# Stop ZNC
./scripts/znc-manager.sh stop

# Remove configuration volume (WARNING: Deletes ALL users and settings)
docker volume rm znc_znc_data

# Restart (will create fresh config)
./scripts/znc-manager.sh start
```

### Delete Specific Users

```bash
# Via web interface: http://localhost:8085 → Global Settings → Users
# Via IRC: /msg *controlpanel deluser <username>
# Via container shell:
./scripts/znc-manager.sh shell
znc --debug  # Then use controlpanel commands
```

## Advanced Configuration

### Password-less Authentication Options

#### 1. Host-based Authentication (Pre-configured for 10.0.0.* subnet)
This setup is pre-configured to allow connections from the 10.0.0.* subnet without passwords:

- **Allowed Network**: `10.0.0.*` (all hosts in your local subnet)
- **No Password Required**: Clients from this network can connect without authentication
- **Automatic Configuration**: Set up during container startup

To modify allowed hosts:
1. In ZNC web interface, go to User Settings
2. Update "Allowed Hosts" field (supports wildcards like `192.168.*.*`)
3. Save configuration

#### 2. Unix Socket Authentication
For local connections, you can use Unix domain sockets:

1. Configure ZNC to listen on a Unix socket instead of TCP port
2. Only local processes can access the socket
3. No password required for socket connections

Add to your ZNC config:
```
<Listener unix>
    AllowIRC = true
    AllowWeb = false
    Socket = /tmp/znc.sock
</Listener>
```

### Custom Modules

To add custom ZNC modules:

1. Mount module directory in `docker-compose.yml`
2. Install modules in the container
3. Load modules via web interface or configuration

### Reverse Proxy Setup

The docker-compose.yml includes Traefik labels for reverse proxy setup:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.znc.rule=Host(`znc.yourdomain.com`)"
  - "traefik.http.routers.znc.tls=true"
```

### Multiple Networks

Configure multiple IRC networks in the web interface or by editing `znc.conf`.

### Local Development Overrides

For local customizations without modifying tracked files:

```bash
# Copy the example override file
cp docker-compose.override.yml.example docker-compose.override.yml

# Edit with your local settings
nano docker-compose.override.yml

# docker-compose automatically merges override files
./scripts/znc-manager.sh start
```

The override file is git-ignored and won't be committed.

## Support

For issues and questions:

1. Check ZNC documentation: https://znc.in/
2. Review container logs: `./scripts/znc-manager.sh logs`
3. Check Docker Compose status: `docker-compose ps`

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Before committing, run the pre-commit check:
```bash
./scripts/pre-commit-check.sh
```

## License

This project is provided as-is under the MIT License. ZNC itself is licensed under the Apache License 2.0.
