#!/usr/bin/env bash
#
# SSH into the Minikube EC2 instance with port forwarding
#
# Usage:
#   ./scripts/ssh-minikube.sh                    # SSH with default port forwarding
#   ./scripts/ssh-minikube.sh --no-forward       # SSH without port forwarding
#   ./scripts/ssh-minikube.sh --custom-ports     # SSH with custom port forwarding
#   ./scripts/ssh-minikube.sh --help             # Show help

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
SSH_KEY=""
SSH_USER="ecoutu"
FORWARD_PORTS=true

# Default ports to forward
# Format: local_port:remote_port
declare -a DEFAULT_PORTS=(
    "8443:8443"   # Kubernetes API Server (minikube default)
    "30080:30080" # NodePort for sample-app
    "30000:30000" # NodePort range start
    "32767:32767" # NodePort range end
)

# Function to print colored messages
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Function to show usage
show_help() {
    cat << EOF
${GREEN}Minikube SSH Script${NC}

SSH into the Minikube EC2 instance with automatic port forwarding for Kubernetes services.

${YELLOW}Usage:${NC}
    $0 [OPTIONS]

${YELLOW}Options:${NC}
    --no-forward        SSH without port forwarding
    --custom-ports      Prompt for custom port forwarding configuration
    --key PATH          Path to SSH private key (optional, uses default SSH config if not specified)
    --user USER         SSH user (default: ecoutu)
    --help              Show this help message

${YELLOW}Default Port Forwarding:${NC}
    8443:8443          Kubernetes API Server (minikube)
    30080:30080        Sample app NodePort service
    30000:30000        NodePort range start
    32767:32767        NodePort range end

${YELLOW}Examples:${NC}
    # SSH with default port forwarding
    $0

    # SSH without any port forwarding
    $0 --no-forward

    # SSH with custom SSH key
    $0 --key ~/.ssh/minikube_rsa

    # SSH with custom ports
    $0 --custom-ports

${YELLOW}After connecting:${NC}
    # Check minikube status
    minikube status

    # Access Kubernetes cluster
    kubectl get nodes
    kubectl get pods -A

    # Access the sample app locally (if port forwarding enabled)
    # Open http://localhost:30080 in your browser

EOF
}

# Function to get instance IP from Terraform output
get_instance_ip() {
    local ip
    ip=$(cd terraform && terraform output -raw minikube_public_ip 2>/dev/null || echo "")

    if [[ -z "$ip" ]]; then
        print_error "Could not get instance IP from Terraform output"
        print_info "Make sure you have run 'terraform apply' and the minikube instance is running"
        exit 1
    fi

    echo "$ip"
}

# Function to build SSH port forwarding arguments
build_port_forward_args() {
    local args=""
    for port in "${DEFAULT_PORTS[@]}"; do
        args="$args -L ${port}"
    done
    echo "$args"
}

# Function to get custom ports from user
get_custom_ports() {
    print_info "Enter custom ports to forward (format: local:remote)"
    print_info "Press Enter with empty input to finish"

    local custom_ports=()
    while true; do
        read -p "Port mapping (e.g., 8080:80): " port_mapping
        if [[ -z "$port_mapping" ]]; then
            break
        fi

        if [[ "$port_mapping" =~ ^[0-9]+:[0-9]+$ ]]; then
            custom_ports+=("$port_mapping")
            print_success "Added: $port_mapping"
        else
            print_warning "Invalid format. Use format: local_port:remote_port"
        fi
    done

    if [[ ${#custom_ports[@]} -eq 0 ]]; then
        print_warning "No ports specified, using defaults"
        echo ""
    else
        # Replace default ports with custom ports
        DEFAULT_PORTS=("${custom_ports[@]}")
        echo ""
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-forward)
            FORWARD_PORTS=false
            shift
            ;;
        --custom-ports)
            get_custom_ports
            shift
            ;;
        --key)
            SSH_KEY="$2"
            shift 2
            ;;
        --user)
            SSH_USER="$2"
            shift 2
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
done

# Main execution
main() {
    print_info "Connecting to Minikube instance..."
    echo ""

    # Get instance IP
    print_info "Getting Minikube instance IP from Terraform..."
    INSTANCE_IP=$(get_instance_ip)
    print_success "Found instance: $INSTANCE_IP"
    echo ""

    # Build SSH command
    local ssh_cmd="ssh"

    # Add SSH key if specified
    if [[ -n "$SSH_KEY" ]]; then
        if [[ ! -f "$SSH_KEY" ]]; then
            print_error "SSH key not found: $SSH_KEY"
            exit 1
        fi
        ssh_cmd="$ssh_cmd -i $SSH_KEY"
        print_info "Using SSH key: $SSH_KEY"
    else
        print_info "Using default SSH configuration"
    fi
    echo ""

    if [[ "$FORWARD_PORTS" == true ]]; then
        print_info "Port forwarding enabled:"
        for port in "${DEFAULT_PORTS[@]}"; do
            local local_port="${port%%:*}"
            local remote_port="${port##*:}"
            echo "  localhost:${local_port} → minikube:${remote_port}"
            ssh_cmd="$ssh_cmd -L ${local_port}:localhost:${remote_port}"
        done
        echo ""
        print_info "After connecting, you can access services at:"
        print_info "  - Kubernetes API: https://localhost:8443"
        print_info "  - Sample App: http://localhost:30080"
        echo ""
    else
        print_info "Port forwarding disabled"
        echo ""
    fi

    print_success "Connecting to ${SSH_USER}@${INSTANCE_IP}..."
    print_info "Press Ctrl+D or type 'exit' to disconnect"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Execute SSH connection
    $ssh_cmd "${SSH_USER}@${INSTANCE_IP}"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "Disconnected from Minikube instance"
}

# Run main function
main
