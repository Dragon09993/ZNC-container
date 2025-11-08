#!/bin/bash

# ZNC Docker Management Script

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if .env file exists
check_env_file() {
    if [ ! -f "$PROJECT_DIR/.env" ]; then
        log_warning ".env file not found. Creating from template..."
        cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
        log_info "Please edit .env file with your configuration before starting ZNC"
        return 1
    fi
    return 0
}

# Function to build ZNC container
build_znc() {
    log_info "Building ZNC Docker container..."
    cd "$PROJECT_DIR"
    docker-compose build
    log_success "ZNC container built successfully"
}

# Function to start ZNC
start_znc() {
    check_env_file || return 1
    
    log_info "Starting ZNC bouncer..."
    cd "$PROJECT_DIR"
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        log_success "ZNC started successfully"
        log_info "Web interface: http://localhost:8085"
        log_info "IRC SSL port: 6697"
        log_info "IRC non-SSL port: 6667"
    else
        log_error "Failed to start ZNC"
        return 1
    fi
}

# Function to stop ZNC
stop_znc() {
    log_info "Stopping ZNC bouncer..."
    cd "$PROJECT_DIR"
    docker-compose down
    log_success "ZNC stopped"
}

# Function to restart ZNC
restart_znc() {
    log_info "Restarting ZNC bouncer..."
    stop_znc
    start_znc
}

# Function to show ZNC logs
show_logs() {
    cd "$PROJECT_DIR"
    docker-compose logs -f znc
}

# Function to show ZNC status
show_status() {
    cd "$PROJECT_DIR"
    if docker-compose ps | grep -q "Up"; then
        log_success "ZNC is running"
        docker-compose ps
    else
        log_warning "ZNC is not running"
    fi
}

# Function to backup ZNC configuration
backup_config() {
    BACKUP_DIR="$PROJECT_DIR/backups"
    BACKUP_FILE="$BACKUP_DIR/znc-config-$(date +%Y%m%d-%H%M%S).tar.gz"
    
    mkdir -p "$BACKUP_DIR"
    
    log_info "Creating configuration backup..."
    docker run --rm -v znc_znc_data:/data -v "$BACKUP_DIR":/backup alpine tar czf "/backup/$(basename "$BACKUP_FILE")" -C /data .
    
    if [ $? -eq 0 ]; then
        log_success "Backup created: $BACKUP_FILE"
    else
        log_error "Backup failed"
        return 1
    fi
}

# Function to restore ZNC configuration
restore_config() {
    if [ -z "$1" ]; then
        log_error "Please specify backup file path"
        return 1
    fi
    
    BACKUP_FILE="$1"
    
    if [ ! -f "$BACKUP_FILE" ]; then
        log_error "Backup file not found: $BACKUP_FILE"
        return 1
    fi
    
    log_warning "This will overwrite current ZNC configuration!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Restoring configuration from $BACKUP_FILE..."
        stop_znc
        docker run --rm -v znc_znc_data:/data -v "$(dirname "$BACKUP_FILE")":/backup alpine sh -c "cd /data && tar xzf /backup/$(basename "$BACKUP_FILE")"
        start_znc
        log_success "Configuration restored"
    else
        log_info "Restore cancelled"
    fi
}

# Function to show help
show_help() {
    echo "ZNC Docker Management Script"
    echo
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  build       Build ZNC Docker container"
    echo "  start       Start ZNC bouncer"
    echo "  stop        Stop ZNC bouncer"
    echo "  restart     Restart ZNC bouncer"
    echo "  status      Show ZNC status"
    echo "  logs        Show ZNC logs (follow mode)"
    echo "  backup      Backup ZNC configuration"
    echo "  restore     Restore ZNC configuration from backup"
    echo "  shell       Open shell in ZNC container"
    echo "  help        Show this help message"
}

# Function to open shell in container
open_shell() {
    cd "$PROJECT_DIR"
    if docker-compose ps | grep -q "Up"; then
        log_info "Opening shell in ZNC container..."
        docker-compose exec znc /bin/bash
    else
        log_error "ZNC container is not running"
        return 1
    fi
}

# Main script logic
case "${1:-help}" in
    "build")
        build_znc
        ;;
    "start")
        start_znc
        ;;
    "stop")
        stop_znc
        ;;
    "restart")
        restart_znc
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs
        ;;
    "backup")
        backup_config
        ;;
    "restore")
        restore_config "$2"
        ;;
    "shell")
        open_shell
        ;;
    "help"|*)
        show_help
        ;;
esac