# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability within this ZNC Docker setup, please send an email to [your-email@example.com]. All security vulnerabilities will be promptly addressed.

## Security Best Practices

### Before Deploying to Production:

1. **Change Default Passwords**: 
   - Never use default passwords in production
   - Update the password in `.env` file
   - Change via web interface at http://your-host:8085

2. **Network Security**:
   - Restrict access to your subnet only
   - Use firewall rules to limit port access
   - Consider using VPN for remote access

3. **SSL/TLS**:
   - Use proper SSL certificates for production (not self-signed)
   - Enable SSL on all listeners
   - Use strong SSL/TLS configurations

4. **Keep Updated**:
   - Regularly update the base Docker image
   - Update ZNC to latest stable version
   - Monitor security advisories

5. **Backup Configuration**:
   - Regularly backup ZNC data volume
   - Store backups securely
   - Test restore procedures

### Environment Variables

Never commit `.env` files to git. They contain sensitive information:
- Passwords
- API keys
- Network configuration

Always use `.env.example` as a template and create your own `.env` file locally.
