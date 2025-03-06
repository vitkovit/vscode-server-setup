#!/bin/bash

# Variables (Default Values)
USER=""
PASSWORD=""
DOMAIN=""
EMAIL=""
CODE_SERVER_VERSION=""
PUBLIC_IPv4=$(curl -4 -s ifconfig.me)
PUBLIC_IPv6=$(curl -6 -s ifconfig.me)
INTERACTIVE_MODE=false

# Parse command-line options
while [[ "$1" != "" ]]; do
    case $1 in
        --interactive ) INTERACTIVE_MODE=true
                        ;;
        * )             echo "Invalid option: $1"
                        exit 1
    esac
    shift
done

# Read from config.ini if not interactive
if [ "$INTERACTIVE_MODE" = false ]; then
    if [ -f config.ini ]; then
        source <(grep = config.ini | sed 's/ *= */=/g')
    else
        echo "config.ini file not found. Exiting."
        exit 1
    fi
fi

# Interactive mode
if [ "$INTERACTIVE_MODE" = true ]; then
    read -p "Enter username: " USER
    read -sp "Enter password: " PASSWORD
    echo
    read -p "Enter domain: " DOMAIN
    read -p "Enter email: " EMAIL
fi

# Check if required variables are set
if [ -z "$USER" ] || [ -z "$PASSWORD" ] || [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo "Required variables (USER, PASSWORD, DOMAIN, EMAIL) are not set. Exiting."
    exit 1
fi

# 1. User and Directory Setup
echo "Setting up user and directories..."
sudo useradd -m -s /bin/bash $USER
echo "$USER:$PASSWORD" | sudo chpasswd
sudo usermod -aG sudo $USER
sudo mkdir -p /home/$USER/GitHubProjects
sudo mkdir -p /home/$USER/vscode
sudo mkdir -p /home/$USER/Developer
sudo chown -R $USER:$USER /home/$USER/
echo "User and directories created."

# 2. code-server Download and Installation
echo "Installing code-server..."
sudo apt update
sudo apt install wget -y
wget "https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server_${CODE_SERVER_VERSION}_amd64.deb" -P /home/$USER/vscode
sudo apt install /home/$USER/vscode/code-server_${CODE_SERVER_VERSION}_amd64.deb -y
sudo systemctl enable --now code-server@$USER
echo "code-server installed."

# 3. code-server Configuration (Example: setting password)
echo "Configuring code-server..."
sudo mkdir -p /home/$USER/.config/code-server/
sudo tee /home/$USER/.config/code-server/config.yaml > /dev/null <<EOF
bind-addr: 127.0.0.1:8080
auth: password
password: $LOGIN_PASSWORD
cert: false
EOF

# add a password setting, or other settings as needed.
sudo systemctl restart code-server@$USER
echo "code-server configured."

# 4. Nginx Installation and Configuration
echo "Installing and configuring Nginx..."
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx

sudo tee /etc/nginx/sites-available/code-server > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection upgrade;
        proxy_set_header Accept-Encoding gzip;
    }
}
EOF


sudo ln -sf /etc/nginx/sites-available/code-server /etc/nginx/sites-enabled/
sudo systemctl restart nginx
echo "Nginx configured."

# 5. Firewall Configuration
echo "Configuring firewall..."
sudo ufw allow 80
sudo ufw allow 443
echo "Firewall configured."

# 6. Pause for DNS A Record Setup
echo "Please create a DNS A record for $DOMAIN pointing to the public IP address:"
echo "IPv4: $PUBLIC_IPv4"
echo "IPv6: $PUBLIC_IPv6"
read -p "Press Enter to continue after you have created the DNS record."

# 7. Let's Encrypt SSL Certificate
echo "Installing Let's Encrypt certificates..."
sudo apt install -y certbot python3-certbot-nginx
sudo certbot --non-interactive --redirect --agree-tos --nginx -d $DOMAIN -m $EMAIL
sudo systemctl restart nginx
echo "Let's Encrypt certificates installed."

# 8. Check service status
echo "Checking user service..."
sudo systemctl status code-server@$USER

