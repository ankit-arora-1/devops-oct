# 1. Declaration and Assignment (no spaces around =)
name="DevOps"
port=8080
is_running=true

# 2. Using Variables ($ to access value)
echo "Hello $name"
echo "Service running on port $port"

# 3. Variable Manipulation
name="Super $name"  # Now "Super DevOps"
port=$((port + 1))  # Now 8081

# WRONG: Spaces around =
name = "John"  # Error: command 'name' not found

# RIGHT: No spaces
name="John"

# WRONG: Not quoting with spaces
file=my file.txt  # Error: 'file.txt' command not found

# RIGHT: Quote when spaces present
file="my file.txt"

# WRONG: Using without $
echo name  # Prints: name

# RIGHT: Use $ to get value
echo $name  # Prints: John

--------

# Global variable (available everywhere in script)
GLOBAL_CONFIG="/etc/myapp/config"

function demo() {
    # Local variable (only in this function)
    local temp_file="/tmp/process.tmp"
    
    # Modifying global
    GLOBAL_CONFIG="/new/path"  # Changes globally
}

# Environment variable (available to child processes)
export DATABASE_URL="postgresql://localhost/mydb"

# Read-only variable (constant)
readonly API_VERSION="v2"
API_VERSION="v3"  # Error: readonly variable

--------

# Creating Arrays
servers=("web01" "web02" "db01" "cache01")
ports=(8080 8081 3306 6379)
status=(true false true true)

# Accessing Array Elements
echo ${servers[0]}   # First element: web01
echo ${servers[2]}   # Third element: db01
echo ${servers[@]}   # All elements
echo ${#servers[@]}  # Number of elements: 4

# Adding to Arrays
servers+=("web03")   # Add one element
servers+=(web04 web05)  # Add multiple elements

# Practical Example: Checking Multiple Services
services=("nginx" "mysql" "redis" "docker")

for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo "✓ $service is running"
    else
        echo "✗ $service is down - restarting..."
        systemctl start "$service"
    fi
done

---------

name="DevOps Engineer"

# Length
echo ${#name}  # 15 characters

# Substring
echo ${name:0:6}   # "DevOps" (from position 0, length 6)
echo ${name:7}     # "Engineer" (from position 7 to end)

# Replace
echo ${name/Engineer/Master}  # "DevOps Master"
echo ${name//e/E}  # "DEvOps EnginEEr" (replace all)

# Remove patterns
file="document.backup.tar.gz"
echo ${file%.gz}      # "document.backup.tar" (remove from end)
echo ${file%.*}       # "document.backup.tar" (remove last extension)
echo ${file%%.*}      # "document" (remove all extensions)
echo ${file#*.}       # "backup.tar.gz" (remove from beginning)

----------

# Use default if variable is unset or empty
echo ${USERNAME:-"anonymous"}  # Use "anonymous" if USERNAME not set

# Set and use default
: ${CONFIG_FILE:="/etc/default.conf"}  # Set if not already set

# Exit if variable not set
DB_PASSWORD=${DB_PASSWORD:?Error: DB_PASSWORD must be set}

# Use alternative value if set
echo ${DEBUG:+"Debug mode is ON"}  # Print only if DEBUG is set

-----------

#!/bin/bash
# Smart configuration with defaults and validation

# Environment with defaults
ENVIRONMENT=${ENVIRONMENT:-"development"}
PORT=${PORT:-8080}
LOG_LEVEL=${LOG_LEVEL:-"INFO"}

# Validate required variables
DATABASE_URL=${DATABASE_URL:?Error: DATABASE_URL is required}
API_KEY=${API_KEY:?Error: API_KEY is required}

# Conditional configuration based on environment
if [[ "$ENVIRONMENT" == "production" ]]; then
    LOG_FILE=${LOG_FILE:-"/var/log/app.log"}
    WORKERS=${WORKERS:-4}
else
    LOG_FILE=${LOG_FILE:-"./app.log"}
    WORKERS=${WORKERS:-1}
fi

echo "Starting application:"
echo "  Environment: $ENVIRONMENT"
echo "  Port: $PORT"
echo "  Workers: $WORKERS"
echo "  Log Level: $LOG_LEVEL"
echo "  Log File: $LOG_FILE"

------------

# File/Directory Tests
if [ -f "/etc/passwd" ]; then
    echo "File exists"
fi

if [ -d "/home/user" ]; then
    echo "Directory exists"
fi

if [ -r "$file" ]; then
    echo "File is readable"
fi

if [ -w "$file" ]; then
    echo "File is writable"
fi

if [ -x "$script" ]; then
    echo "File is executable"
fi

# String Comparisons
if [ "$name" = "admin" ]; then
    echo "Admin user"
fi

if [ -z "$variable" ]; then
    echo "Variable is empty"
fi

if [ -n "$variable" ]; then
    echo "Variable is not empty"
fi

# Numeric Comparisons
if [ $age -gt 18 ]; then
    echo "Adult"
fi

if [ $score -le 100 ]; then
    echo "Valid score"
fi

# Modern [[ ]] syntax (more powerful)
if [[ $email =~ ^[a-z]+@[a-z]+\.[a-z]+$ ]]; then
    echo "Valid email format"
fi

if [[ $file == *.log ]]; then
    echo "This is a log file"
fi

-----------

#!/bin/bash

backup_database() {
    local db_name=$1
    local backup_dir="/backup/$(date +%Y%m%d)"
    
    # Create backup directory if it doesn't exist
    if [ ! -d "$backup_dir" ]; then
        echo "Creating backup directory: $backup_dir"
        mkdir -p "$backup_dir"
    fi
    
    # Check disk space (need at least 1GB)
    available_space=$(df /backup | awk 'NR==2 {print $4}')
    if [ $available_space -lt 1048576 ]; then
        echo "ERROR: Not enough disk space for backup"
        return 1
    fi
    
    # Check if database is accessible
    if mysqladmin ping -h localhost &>/dev/null; then
        echo "Database is running, starting backup..."
        
        # Perform backup
        if mysqldump "$db_name" > "$backup_dir/${db_name}.sql"; then
            echo "✓ Backup successful"
            
            # Compress if larger than 100MB
            backup_size=$(stat -f%z "$backup_dir/${db_name}.sql" 2>/dev/null || stat -c%s "$backup_dir/${db_name}.sql")
            if [ $backup_size -gt 104857600 ]; then
                echo "Compressing large backup..."
                gzip "$backup_dir/${db_name}.sql"
            fi
        else
            echo "✗ Backup failed"
            return 1
        fi
    else
        echo "ERROR: Database is not running"
        return 1
    fi
}

# Run backup
backup_database "production_db"

-----------

# Instead of this:
if [ "$1" = "start" ]; then
    start_service
elif [ "$1" = "stop" ]; then
    stop_service
elif [ "$1" = "restart" ]; then
    restart_service
elif [ "$1" = "status" ]; then
    check_status
else
    show_help
fi

# Use this elegant case statement:
case "$1" in
    start)
        start_service
        ;;
    stop)
        stop_service
        ;;
    restart)
        stop_service
        start_service
        ;;
    status)
        check_status
        ;;
    *)
        show_help
        ;;
esac

----------

#!/bin/bash
# File processor based on extension

process_file() {
    local file="$1"
    
    case "$file" in
        *.jpg|*.jpeg|*.png)
            echo "Processing image: $file"
            convert "$file" -resize 800x600 "thumb_$file"
            ;;
        *.mp4|*.avi|*.mov)
            echo "Processing video: $file"
            ffmpeg -i "$file" -codec copy "compressed_$file"
            ;;
        *.log)
            echo "Archiving log: $file"
            gzip "$file"
            ;;
        *.tar.gz|*.tgz)
            echo "Extracting archive: $file"
            tar -xzf "$file"
            ;;
        *.txt|*.md)
            echo "Counting words in: $file"
            wc -w "$file"
            ;;
        *)
            echo "Unknown file type: $file"
            ;;
    esac
}

# Process all files in current directory
for file in *; do
    process_file "$file"
done

-----------

# Loop through list
for server in web01 web02 db01; do
    echo "Checking $server..."
    ping -c 1 "$server" &>/dev/null && echo "$server is up" || echo "$server is down"
done

# Loop through array
services=("nginx" "mysql" "redis")
for service in "${services[@]}"; do
    systemctl status "$service"
done

# Loop through numbers
for i in {1..10}; do
    echo "Creating user$i"
    useradd "user$i"
done

# C-style for loop
for ((i=0; i<5; i++)); do
    echo "Iteration $i"
done

# Loop through command output
for file in $(find /logs -name "*.log" -size +100M); do
    echo "Compressing large log: $file"
    gzip "$file"
done

-------------


# While condition is true
counter=0
while [ $counter -lt 10 ]; do
    echo "Count: $counter"
    ((counter++))
done

# Reading file line by line
while IFS= read -r line; do
    echo "Processing: $line"
    # Process each line
done < servers.txt

# Infinite loop with break condition
while true; do
    if ping -c 1 google.com &>/dev/null; then
        echo "Internet is up!"
        break
    else
        echo "Waiting for internet..."
        sleep 5
    fi
done

# Menu system
while true; do
    echo "1) Start services"
    echo "2) Stop services"
    echo "3) Check status"
    echo "4) Exit"
    read -p "Choose option: " choice
    
    case $choice in
        1) start_all ;;
        2) stop_all ;;
        3) status_all ;;
        4) break ;;
        *) echo "Invalid option" ;;
    esac
done


------------


# Keep trying until successful
until mysqladmin ping &>/dev/null; do
    echo "Waiting for MySQL to start..."
    sleep 2
done
echo "MySQL is ready!"

# Retry mechanism
attempts=0
until [ $attempts -ge 5 ]; do
    if curl -s http://api.example.com/health; then
        echo "API is responding"
        break
    fi
    attempts=$((attempts + 1))
    echo "Attempt $attempts failed, retrying..."
    sleep 5
done

-----------

# Function definition
function say_hello() {
    echo "Hello, DevOps!"
}

# Alternative syntax
say_goodbye() {
    echo "Goodbye!"
}

# Calling functions
say_hello
say_goodbye

-------------

# Function with parameters
greet_user() {
    local name=$1
    local role=$2
    echo "Welcome $name, you are logged in as $role"
}

# Calling with arguments
greet_user "Alice" "Admin"
greet_user "Bob" "Developer"

# Function with all parameters
process_all() {
    echo "Processing $# items"
    for item in "$@"; do
        echo "  - $item"
    done
}

process_all file1.txt file2.txt file3.txt

--------------

# Functions can return exit codes (0-255)
validate_email() {
    local email=$1
    if [[ $email =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 0  # Success
    else
        return 1  # Failure
    fi
}

# Using the return value
if validate_email "user@example.com"; then
    echo "Valid email"
else
    echo "Invalid email"
fi

# Returning data (using echo and command substitution)
calculate_percentage() {
    local value=$1
    local total=$2
    local percentage=$(( (value * 100) / total ))
    echo $percentage
}

# Capture the output
result=$(calculate_percentage 25 100)
echo "Percentage: $result%"

---------


#!/bin/bash
# lib/utils.sh - Reusable function library

# Logging functions
log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" >&2 | tee -a "$LOG_FILE"
}

log_success() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✓ SUCCESS: $*" | tee -a "$LOG_FILE"
}

# Check if service is running
is_service_running() {
    local service=$1
    systemctl is-active --quiet "$service"
}

# Restart service with retry
restart_service_safe() {
    local service=$1
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log_info "Attempting to restart $service (attempt $attempt/$max_attempts)"
        
        systemctl restart "$service"
        sleep 2
        
        if is_service_running "$service"; then
            log_success "$service restarted successfully"
            return 0
        fi
        
        ((attempt++))
    done
    
    log_error "Failed to restart $service after $max_attempts attempts"
    return 1
}

# Check disk usage
check_disk_usage() {
    local threshold=${1:-90}  # Default 90%
    local alert_sent=false
    
    while IFS= read -r line; do
        usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
        partition=$(echo "$line" | awk '{print $6}')
        
        if [ "$usage" -gt "$threshold" ]; then
            log_error "High disk usage on $partition: ${usage}%"
            alert_sent=true
        fi
    done < <(df -h | grep -v "^Filesystem")
    
    if [ "$alert_sent" = false ]; then
        log_info "All disk partitions below ${threshold}% threshold"
    fi
}

# Backup with rotation
backup_with_rotation() {
    local source_dir=$1
    local backup_dir=$2
    local keep_days=${3:-7}
    
    # Create backup
    local backup_name="backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$backup_dir/$backup_name" -C "$source_dir" .
    
    if [ $? -eq 0 ]; then
        log_success "Backup created: $backup_name"
        
        # Remove old backups
        find "$backup_dir" -name "backup_*.tar.gz" -mtime +$keep_days -delete
        log_info "Removed backups older than $keep_days days"
    else
        log_error "Backup failed for $source_dir"
        return 1
    fi
}

-------------

#!/bin/bash
# main_script.sh - Using modular design

# Source the library
source ./lib/utils.sh
source ./lib/database.sh
source ./lib/monitoring.sh

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_FILE="$SCRIPT_DIR/config.conf"
readonly LOG_FILE="/var/log/app_monitor.log"

# Load configuration
load_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        log_info "Configuration loaded from $CONFIG_FILE"
    else
        log_error "Configuration file not found: $CONFIG_FILE"
        exit 1
    fi
}

# Main monitoring function
perform_health_check() {
    log_info "Starting health check"
    
    # Use functions from libraries
    check_disk_usage 85
    check_memory_usage
    check_database_connectivity
    check_api_endpoints
    
    log_info "Health check completed"
}

# Script entry point
main() {
    load_config
    
    case "${1:-}" in
        --check)
            perform_health_check
            ;;
        --backup)
            backup_with_rotation "$APP_DIR" "$BACKUP_DIR" 7
            ;;
        --monitor)
            while true; do
                perform_health_check
                sleep 300  # Check every 5 minutes
            done
            ;;
        *)
            echo "Usage: $0 {--check|--backup|--monitor}"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"

----------


# Every command returns an exit code
ls /etc/passwd
echo $?  # 0 - success

ls /nonexistent
echo $?  # 2 - file not found

# Common exit codes
# 0   - Success
# 1   - General errors
# 2   - Misuse of shell commands
# 126 - Command cannot execute
# 127 - Command not found
# 128 - Invalid argument to exit
# 130 - Script terminated by Ctrl-C

--------------

#!/bin/bash

# Define custom exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_GENERAL_ERROR=1
readonly EXIT_FILE_NOT_FOUND=2
readonly EXIT_PERMISSION_DENIED=3
readonly EXIT_DEPENDENCY_MISSING=4

# Check dependencies
check_dependencies() {
    local deps=("curl" "jq" "docker")
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo "Error: Required dependency '$dep' is not installed"
            exit $EXIT_DEPENDENCY_MISSING
        fi
    done
}

# Process file with proper error handling
process_config_file() {
    local config_file=$1
    
    if [ ! -f "$config_file" ]; then
        echo "Error: Configuration file not found: $config_file"
        exit $EXIT_FILE_NOT_FOUND
    fi
    
    if [ ! -r "$config_file" ]; then
        echo "Error: Cannot read configuration file: $config_file"
        exit $EXIT_PERMISSION_DENIED
    fi
    
    # Process the file
    source "$config_file" || exit $EXIT_GENERAL_ERROR
}

# Main execution
main() {
    check_dependencies
    process_config_file "/etc/myapp/config.conf"
    
    echo "Script completed successfully"
    exit $EXIT_SUCCESS
}

main "$@"

--------------

#!/bin/bash

# Error handling library
error_exit() {
    echo "ERROR: $1" >&2
    exit "${2:-1}"
}

try() {
    [[ $- = *e* ]]; SAVED_OPT_E=$?
    set +e
}

catch() {
    export exception_code=$?
    (( SAVED_OPT_E )) && set +e
    return $exception_code
}

# Usage example
deploy_application() {
    local app_name=$1
    local environment=$2
    
    # Validate inputs
    [[ -z "$app_name" ]] && error_exit "Application name is required" 2
    [[ -z "$environment" ]] && error_exit "Environment is required" 2
    
    # Try risky operation
    try
        echo "Deploying $app_name to $environment"
        
        # Stop old version
        docker stop "$app_name" 2>/dev/null
        docker rm "$app_name" 2>/dev/null
        
        # Deploy new version
        docker run -d --name "$app_name" "myapp:latest"
        
    catch || {
        case $exception_code in
            125)
                error_exit "Docker daemon is not running" 3
                ;;
            126)
                error_exit "Permission denied - need sudo" 4
                ;;
            *)
                error_exit "Deployment failed with code $exception_code" 5
                ;;
        esac
    }
    
    echo "✓ Deployment successful"
}

----------
