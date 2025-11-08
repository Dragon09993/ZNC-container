# Contributing to ZNC Docker Setup

Thank you for considering contributing to this project!

## How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your changes locally
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Development Setup

```bash
# Clone your fork
git clone https://github.com/your-username/ZNC.git
cd ZNC

# Copy environment template
cp .env.example .env

# Edit .env with your settings
nano .env

# Build and start
./scripts/znc-manager.sh build
./scripts/znc-manager.sh start
```

## Guidelines

### Code Style
- Use clear, descriptive variable names
- Comment complex sections
- Follow existing code patterns
- Test your changes before submitting

### Commit Messages
- Use clear, descriptive commit messages
- Start with a verb (Add, Fix, Update, Remove)
- Keep first line under 50 characters
- Add detailed description if needed

### Pull Requests
- Describe what your PR does
- Reference any related issues
- Include testing steps
- Update documentation if needed

## Testing

Before submitting a PR:
1. Test with a fresh build
2. Verify existing functionality still works
3. Test with different configurations
4. Check logs for errors

## Questions?

Feel free to open an issue for:
- Bug reports
- Feature requests
- Documentation improvements
- Questions about usage
