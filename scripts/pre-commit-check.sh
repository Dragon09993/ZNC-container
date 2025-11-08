#!/bin/bash

# Pre-commit checks for ZNC Docker setup
# Run this before committing to ensure no sensitive data is included

echo "🔍 Checking for sensitive files..."

FAIL=0

# Check if .env is being committed
if git diff --cached --name-only | grep -q "^.env$"; then
    echo "❌ ERROR: .env file is staged for commit!"
    echo "   Run: git reset HEAD .env"
    FAIL=1
fi

# Check if docker-compose.override.yml is being committed
if git diff --cached --name-only | grep -q "^docker-compose.override.yml$"; then
    echo "⚠️  WARNING: docker-compose.override.yml is staged for commit"
    echo "   This file may contain local settings"
    FAIL=1
fi

# Check for password in staged files
if git diff --cached | grep -i "password.*=" | grep -v "CHANGE_THIS_PASSWORD" | grep -v ".env.example"; then
    echo "⚠️  WARNING: Possible password found in staged changes"
    echo "   Please review your changes"
fi

# Check for common sensitive patterns
if git diff --cached | grep -E "(api[_-]?key|secret|token|password)" | grep -v ".env.example" | grep -v "# "; then
    echo "⚠️  WARNING: Possible sensitive data in staged changes"
fi

if [ $FAIL -eq 1 ]; then
    echo ""
    echo "❌ Pre-commit check FAILED"
    echo "   Please fix the issues above before committing"
    exit 1
fi

echo "✅ Pre-commit checks passed!"
exit 0
