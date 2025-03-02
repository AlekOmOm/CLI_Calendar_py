#!/bin/bash
# init_repo.sh - Repository initialization script

echo "===== CLI Calendar Python Setup ====="
echo "This script will set up your environment and GitHub secrets."

# Create basic directory structure
mkdir -p cli_calendar/utils
touch cli_calendar/__init__.py
touch cli_calendar/main.py

# Create .env file from prompts
echo "Setting up .env file..."
echo "# CLI Calendar Configuration" > .env

read -p "Calendar API URL [https://api.calendar.example.com]: " cal_api_url
cal_api_url=${cal_api_url:-https://api.calendar.example.com}
echo "CALENDAR_API_URL=$cal_api_url" >> .env

read -p "App environment [development]: " app_env
app_env=${app_env:-development}
echo "APP_ENV=$app_env" >> .env

# Copy .env to .env.example with placeholders
sed 's/=.*/=YOUR_VALUE_HERE/g' .env > .env.example

# Add .env to .gitignore if not already present
if ! grep -q ".env" .gitignore 2>/dev/null; then
    echo ".env" >> .gitignore
fi

# Set up GitHub secrets if gh CLI is available
if command -v gh &>/dev/null; then
    echo "Setting up GitHub secrets..."
    
    read -p "Do you want to set up GitHub secrets? (y/n): " setup_secrets
    if [[ "$setup_secrets" == "y" ]]; then
        read -sp "Calendar API Key: " api_key
        echo
        gh secret set CALENDAR_API_KEY -b "$api_key"
        
        read -p "Do you need to set up deployment secrets? (y/n): " setup_deploy
        if [[ "$setup_deploy" == "y" ]]; then
            read -p "Server Host: " server_host
            gh secret set SERVER_HOST -b "$server_host"
            
            read -p "Server User: " server_user
            gh secret set SERVER_USER -b "$server_user"
            
            read -p "SSH Port [22]: " ssh_port
            ssh_port=${ssh_port:-22}
            gh secret set SSH_PORT -b "$ssh_port"
            
            read -p "Path to SSH private key file: " key_file
            if [[ -f "$key_file" ]]; then
                gh secret set SSH_PRIVATE_KEY < "$key_file"
                echo "SSH key added successfully!"
            else
                echo "Error: SSH key file not found!"
            fi
        fi
    fi
else
    echo "GitHub CLI not found. Skipping secrets setup."
    echo "You can manually set secrets later with: gh secret set SECRET_NAME"
fi

# Set up Python virtual environment
echo "Setting up Python virtual environment..."
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt 2>/dev/null || echo "No requirements.txt found, skipping pip install"

echo "===== Setup Complete ====="
echo "Next steps:"
echo "1. Activate virtual environment: source venv/bin/activate"
echo "2. Start developing!"
