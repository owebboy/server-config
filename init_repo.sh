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