#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

show_banner() {
    echo -e "${BLUE}"
    echo '███╗   ██╗██╗    ██╗ █████╗ ██╗  ██╗██╗   ██╗    ███╗   ██╗ ██████╗ ██████╗ ███████╗'
    echo '████╗  ██║██║    ██║██╔══██╗██║ ██╔╝██║   ██║    ████╗  ██║██╔═══██╗██╔══██╗██╔════╝'
    echo '██╔██╗ ██║██║ █╗ ██║███████║█████╔╝ ██║   ██║    ██╔██╗ ██║██║   ██║██║  ██║█████╗  '
    echo '██║╚██╗██║██║███╗██║██╔══██║██╔═██╗ ██║   ██║    ██║╚██╗██║██║   ██║██║  ██║██╔══╝  '
    echo '██║ ╚████║╚███╔███╔╝██║  ██║██║  ██╗╚██████╔╝    ██║ ╚████║╚██████╔╝██████╔╝███████╗'
    echo '╚═╝  ╚═══╝ ╚══╝╚══╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝     ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝'
    echo -e "${NC}"
    echo -e "${CYAN}===========================================================================${NC}"
    echo -e "${PURPLE}                     Auto Installation Nwaku${NC}"
    echo -e "${PURPLE}                     Author: Galkurta${NC}"
    echo -e "${PURPLE}                     Github: https://github.com/Galkurta${NC}"
    echo -e "${CYAN}===========================================================================${NC}"
    echo
}

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_status() {
    if [ $? -eq 0 ]; then
        print_message "$1 successful"
    else
        print_error "$1 failed"
        exit 1
    fi
}


configure_env() {
    print_message "Configuring .env file..."
    

    if [ -f .env ]; then
        mv .env .env.backup
        print_message "Backed up existing .env to .env.backup"
    fi

    print_message "Please enter the following configuration details:"
    echo

    read -p "Enter your Sepolia RPC URL (e.g., https://sepolia.infura.io/v3/YOUR-KEY): " rpc_url
    while [[ -z "$rpc_url" ]]; do
        print_error "RPC URL cannot be empty"
        read -p "Enter your Sepolia RPC URL: " rpc_url
    done

    read -p "Enter your testnet private key (without 0x prefix): " eth_key
    while [[ -z "$eth_key" || "${eth_key:0:2}" == "0x" ]]; do
        if [[ "${eth_key:0:2}" == "0x" ]]; then
            print_error "Private key should not include 0x prefix"
        else
            print_error "Private key cannot be empty"
        fi
        read -p "Enter your testnet private key (without 0x prefix): " eth_key
    done

    read -p "Enter password for RLN membership (minimum 8 characters): " rln_password
    while [[ ${#rln_password} -lt 8 ]]; do
        print_error "Password must be at least 8 characters long"
        read -p "Enter password for RLN membership: " rln_password
    done

    echo
    print_message "Advanced configuration (press Enter to skip):"
    read -p "Enter NWAKU_IMAGE (optional): " nwaku_image
    read -p "Enter NODEKEY (optional): " nodekey
    read -p "Enter DOMAIN (optional): " domain
    read -p "Enter EXTRA_ARGS (optional): " extra_args
    read -p "Enter STORAGE_SIZE (optional): " storage_size

    cat > .env << EOF
# RPC URL for accessing testnet via HTTP
RLN_RELAY_ETH_CLIENT_ADDRESS=$rpc_url

# Private key of testnet
ETH_TESTNET_KEY=$eth_key

# Password for RLN membership
RLN_RELAY_CRED_PASSWORD="$rln_password"

# Advanced configuration
NWAKU_IMAGE=$nwaku_image
NODEKEY=$nodekey
DOMAIN=$domain
EXTRA_ARGS=$extra_args
STORAGE_SIZE=$storage_size
EOF
    
    print_message ".env file has been configured successfully"

    echo
    print_message "Configuration Summary:"
    echo "----------------------------------------"
    echo "RPC URL: $rpc_url"
    echo "Private Key: ${eth_key:0:4}...${eth_key: -4}"
    echo "RLN Password: [HIDDEN]"
    if [[ ! -z "$nwaku_image" ]]; then echo "NWAKU_IMAGE: $nwaku_image"; fi
    if [[ ! -z "$nodekey" ]]; then echo "NODEKEY: $nodekey"; fi
    if [[ ! -z "$domain" ]]; then echo "DOMAIN: $domain"; fi
    if [[ ! -z "$extra_args" ]]; then echo "EXTRA_ARGS: $extra_args"; fi
    if [[ ! -z "$storage_size" ]]; then echo "STORAGE_SIZE: $storage_size"; fi
    echo "----------------------------------------"

    read -p "Is this configuration correct? (y/n): " confirm
    if [[ $confirm != "y" ]]; then
        print_message "Restarting configuration..."
        configure_env
    fi
}

install_prerequisites() {
    print_message "Starting prerequisites installation..."

    print_message "Updating system packages..."
    sudo apt update && sudo apt upgrade -y
    check_status "System update"

    print_message "Installing git..."
    sudo apt-get install git -y
    check_status "Git installation"

    print_message "Configuring firewall rules..."
    sudo ufw allow 30304/tcp
    sudo ufw allow 30304/udp
    sudo ufw allow 9005/udp
    sudo ufw allow 3000/tcp
    sudo ufw allow 5432/tcp
    sudo ufw allow 4000/tcp
    sudo ufw allow 8000/tcp
    check_status "Firewall configuration"
}

install_docker() {
    if ! command -v docker &> /dev/null; then
        print_message "Installing Docker..."
        sudo apt install docker.io -y
        check_status "Docker installation"
        
        print_message "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        check_status "Docker Compose installation"
        
        docker --version
    else
        print_message "Docker is already installed"
    fi
}

install_nwaku() {
    print_message "Installing Nwaku node..."
    git clone https://github.com/waku-org/nwaku-compose && cd nwaku-compose
    check_status "Nwaku repository cloning"
    
    cp .env.example .env
    configure_env
}

register_rln() {
    print_message "Registering RLN membership..."
    read -p "Do you want to register for RLN membership? (y/n): " register
    if [[ $register == "y" ]]; then
        ./register_rln.sh
        check_status "RLN membership registration"
    fi
}

set_storage() {
    print_message "Setting storage allocation..."
    ./set_storage_retention.sh
    check_status "Storage allocation setup"
}

start_nwaku() {
    print_message "Starting Nwaku node..."
    docker-compose up -d && docker-compose logs -f nwaku
    check_status "Nwaku node startup"
}

show_menu() {
    clear
    show_banner
    echo "                  MAIN MENU"
    echo "============================================"
    echo "1. Install Prerequisites"
    echo "2. Install Docker (if not installed)"
    echo "3. Install Nwaku Node"
    echo "4. Register RLN Membership"
    echo "5. Set Storage Allocation"
    echo "6. Start Nwaku Node"
    echo "7. Update Nwaku Node"
    echo "8. Restart Nwaku Node"
    echo "9. Shutdown Nwaku Node"
    echo "10. Delete Nwaku Node"
    echo "11. Reconfigure .env File"
    echo "0. Exit"
    echo "============================================"
}

update_nwaku() {
    print_message "Updating Nwaku node..."
    cd nwaku-compose && \
    docker-compose down && \
    git pull origin master && \
    docker-compose up -d
    check_status "Nwaku node update"
}

restart_nwaku() {
    print_message "Restarting Nwaku node..."
    sudo docker-compose -f "$HOME/nwaku-compose/docker-compose.yml" down && \
    sudo docker-compose -f "$HOME/nwaku-compose/docker-compose.yml" up -d
    check_status "Nwaku node restart"
}

shutdown_nwaku() {
    print_message "Shutting down Nwaku node..."
    sudo docker-compose -f "$HOME/nwaku-compose/docker-compose.yml" down
    check_status "Nwaku node shutdown"
}

delete_nwaku() {
    print_message "Deleting Nwaku node..."
    read -p "Are you sure you want to delete Nwaku node? This cannot be undone (y/n): " confirm
    if [[ $confirm == "y" ]]; then
        sudo docker-compose -f "$HOME/nwaku-compose/docker-compose.yml" down && rm -r $HOME/nwaku-compose/
        check_status "Nwaku node deletion"
    else
        print_message "Deletion cancelled"
    fi
}

# Main script execution
while true; do
    show_menu
    read -p "Enter your choice (0-11): " choice
    
    case $choice in
        1) install_prerequisites ;;
        2) install_docker ;;
        3) install_nwaku ;;
        4) register_rln ;;
        5) set_storage ;;
        6) start_nwaku ;;
        7) update_nwaku ;;
        8) restart_nwaku ;;
        9) shutdown_nwaku ;;
        10) delete_nwaku ;;
        11) 
            if [ -d "nwaku-compose" ]; then
                cd nwaku-compose && configure_env
            else
                print_error "Nwaku directory not found. Install Nwaku first."
            fi
            ;;
        0) 
            print_message "Exiting..."
            exit 0
            ;;
        *)
            print_error "Invalid option"
            ;;
    esac
    
    echo
    read -p "Press Enter to continue..."
done