#!/bin/bash
#
# Repository initialization script
# Description: Initialize the git repository and prepare for deployment
#

# Color codes for output
GREEN='\033[0;32m'
NC='\033[0m'  # No Color

echo -e "${GREEN}Initializing Git repository...${NC}"
git init

# Create configs directory if it doesn't exist
mkdir -p public/configs

# Copy config files to public/configs
cp -f configs/* public/configs/ 2>/dev/null || true

# Copy server_setup.sh to public directory
cp -f server_setup.sh public/ 2>/dev/null || true

# Check if the _headers file exists and contains Content-Type header
if ! grep -q "Content-Type: text/plain" public/_headers 2>/dev/null; then
    echo -e "${GREEN}Creating/updating _headers file for Cloudflare Pages...${NC}"
    echo "# Headers for Cloudflare Pages
# Set Content-Type header for all files in configs directory to text/plain

/configs/*
  Content-Type: text/plain" > public/_headers
fi

# Set up redirects file
echo -e "${GREEN}Creating/updating _redirects file for Cloudflare Pages...${NC}"
echo "# Redirects for Cloudflare Pages
# Redirect root-level config files to the configs directory

/bashrc /configs/bashrc 301
/vimrc /configs/vimrc 301
/tmux.conf /configs/tmux.conf 301
/gitconfig /configs/gitconfig 301
/screenrc /configs/screenrc 301
/inputrc /configs/inputrc 301
/ssh_config /configs/ssh_config 301
/bash_functions /configs/bash_functions 301
/gitignore_global /configs/gitignore_global 301
/dircolors /configs/dircolors 301" > public/_redirects

echo -e "${GREEN}Adding files to repository...${NC}"
git add configs/ public/ setup_server.sh server_setup.sh README.md CLAUDE.md .gitignore init_repo.sh

echo -e "${GREEN}Creating initial commit...${NC}"
git commit -m "Initial commit - Server Configuration Manager"

echo -e "${GREEN}Repository initialized successfully!${NC}"
echo "Next steps:"
echo "1. Create a repository on GitHub or another Git hosting service"
echo "2. Link your remote repository with:"
echo "   git remote add origin https://github.com/username/server-config.git"
echo "3. Push your code with:"
echo "   git branch -M main"
echo "   git push -u origin main"
echo "4. Set up Cloudflare Pages as described in the README.md file"