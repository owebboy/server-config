#!/bin/bash
#
# Server Setup Script
# Description: Automatically configure a new Linux server with standard dotfiles
# Usage: ./setup_server.sh [--force] [--create-web-configs] [--local] [--help]
#

set -e

CONFIG_URL="https://config.opope.dev/configs"  # Web server URL for config files
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"
FORCE=0
CREATE_WEB_CONFIGS=0
LOCAL_SETUP=0
SHOW_HELP=0

# Display help information
show_help() {
    echo "Server Configuration Setup Script"
    echo "Usage: ./setup_server.sh [OPTIONS]"
    echo
    echo "Options:"
    echo "  --force               Overwrite existing configuration files"
    echo "  --create-web-configs  Create configuration files for web server deployment"
    echo "  --local               Install configuration files from local directory"
    echo "  --help                Display this help message"
    echo
    echo "Examples:"
    echo "  ./setup_server.sh                 # Install configs from web server"
    echo "  ./setup_server.sh --force         # Install configs and overwrite existing files"
    echo "  ./setup_server.sh --local         # Install configs from local directory"
    echo "  ./setup_server.sh --create-web-configs # Create configs for web deployment"
    exit 0
}

# Process arguments
for arg in "$@"; do
    case $arg in
        --force)
            FORCE=1
            ;;
        --create-web-configs)
            CREATE_WEB_CONFIGS=1
            ;;
        --local)
            LOCAL_SETUP=1
            ;;
        --help)
            SHOW_HELP=1
            ;;
    esac
done

# Show help if requested
if [[ $SHOW_HELP -eq 1 ]]; then
    show_help
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log helper functions
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

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Backup an existing file
backup_file() {
    local file="$1"
    if [[ -f "$file" || -d "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp -a "$file" "$BACKUP_DIR/"
        log_info "Backed up $file to $BACKUP_DIR/"
    fi
}

# Download a configuration file
download_config() {
    local file="$1"
    local dest="$2"
    
    # Create parent directory if it doesn't exist
    mkdir -p "$(dirname "$dest")"
    
    if command_exists curl; then
        curl -s "$CONFIG_URL/$file" -o "$dest"
    elif command_exists wget; then
        wget -q "$CONFIG_URL/$file" -O "$dest"
    else
        log_error "Neither curl nor wget is installed. Cannot download files."
        exit 1
    fi
    
    if [[ $? -ne 0 ]]; then
        log_error "Failed to download $file"
        return 1
    fi
    
    chmod 644 "$dest"
    log_success "Downloaded $file to $dest"
    return 0
}

# Setup function for each configuration file
setup_bashrc() {
    local dest="$HOME/.bashrc"
    if [[ -f "$dest" && $FORCE -eq 0 ]]; then
        log_warning "$dest already exists. Use --force to overwrite."
        return 1
    fi
    backup_file "$dest"
    download_config "bashrc" "$dest"
}

setup_vimrc() {
    local dest="$HOME/.vimrc"
    if [[ -f "$dest" && $FORCE -eq 0 ]]; then
        log_warning "$dest already exists. Use --force to overwrite."
        return 1
    fi
    backup_file "$dest"
    download_config "vimrc" "$dest"
}

setup_tmux_conf() {
    local dest="$HOME/.tmux.conf"
    if [[ -f "$dest" && $FORCE -eq 0 ]]; then
        log_warning "$dest already exists. Use --force to overwrite."
        return 1
    fi
    backup_file "$dest"
    download_config "tmux.conf" "$dest"
}

setup_gitconfig() {
    local dest="$HOME/.gitconfig"
    if [[ -f "$dest" && $FORCE -eq 0 ]]; then
        log_warning "$dest already exists. Use --force to overwrite."
        return 1
    fi
    backup_file "$dest"
    download_config "gitconfig" "$dest"
    
    # Prompt for git user configuration
    read -p "Enter your Git user name: " git_name
    read -p "Enter your Git email address: " git_email
    
    # Update the placeholders in the gitconfig
    sed -i "s/CHANGEME/$git_name/g" "$dest" 2>/dev/null || sed -i '' "s/CHANGEME/$git_name/g" "$dest"
    sed -i "s/CHANGEME@example.com/$git_email/g" "$dest" 2>/dev/null || sed -i '' "s/CHANGEME@example.com/$git_email/g" "$dest"
}

setup_screenrc() {
    local dest="$HOME/.screenrc"
    if [[ -f "$dest" && $FORCE -eq 0 ]]; then
        log_warning "$dest already exists. Use --force to overwrite."
        return 1
    fi
    backup_file "$dest"
    download_config "screenrc" "$dest"
}

setup_inputrc() {
    local dest="$HOME/.inputrc"
    if [[ -f "$dest" && $FORCE -eq 0 ]]; then
        log_warning "$dest already exists. Use --force to overwrite."
        return 1
    fi
    backup_file "$dest"
    download_config "inputrc" "$dest"
}

setup_ssh_config() {
    local dest="$HOME/.ssh/config"
    if [[ -f "$dest" && $FORCE -eq 0 ]]; then
        log_warning "$dest already exists. Use --force to overwrite."
        return 1
    fi
    backup_file "$dest"
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    download_config "ssh_config" "$dest"
    chmod 600 "$dest"
}

setup_bash_functions() {
    local dest="$HOME/.bash_functions"
    if [[ -f "$dest" && $FORCE -eq 0 ]]; then
        log_warning "$dest already exists. Use --force to overwrite."
        return 1
    fi
    backup_file "$dest"
    download_config "bash_functions" "$dest"
}

setup_gitignore_global() {
    local dest="$HOME/.gitignore_global"
    if [[ -f "$dest" && $FORCE -eq 0 ]]; then
        log_warning "$dest already exists. Use --force to overwrite."
        return 1
    fi
    backup_file "$dest"
    download_config "gitignore_global" "$dest"
}

setup_dircolors() {
    local dest="$HOME/.dircolors"
    if [[ -f "$dest" && $FORCE -eq 0 ]]; then
        log_warning "$dest already exists. Use --force to overwrite."
        return 1
    fi
    backup_file "$dest"
    download_config "dircolors" "$dest"
}

# Define the list of standard config files
get_config_file_list() {
    echo "bashrc vimrc tmux.conf gitconfig screenrc inputrc ssh_config bash_functions gitignore_global dircolors"
}

# Create/verify config files in configs directory
create_webserver_configs() {
    log_info "Setting up config files for your web server..."
    
    # Create directory structure
    mkdir -p configs
    
    # Get the list of config files
    local config_files=( $(get_config_file_list) )
    
    # Check if each config file exists
    local missing_files=0
    for file in "${config_files[@]}"; do
        if [[ ! -f "configs/$file" ]]; then
            log_warning "Config file $file is missing"
            missing_files=$((missing_files + 1))
        else
            log_info "Config file $file exists"
        fi
    done
    
    # If there are missing files, provide instructions
    if [[ $missing_files -gt 0 ]]; then
        log_warning "$missing_files configuration files are missing."
        
        # Ask if user wants to create template files
        read -p "Would you like to create template files for missing configurations? (y/n): " create_templates
        if [[ $create_templates =~ ^[Yy]$ ]]; then
            create_template_configs
        else
            log_info "You can create these files manually in the configs/ directory."
            log_info "The files should contain your preferred configurations for each tool."
        fi
    else
        log_success "All required config files are present"
    fi
    
    log_info "You can customize these config files and upload them to $CONFIG_URL"
}

# Create template config files for missing configurations
create_template_configs() {
    log_info "Creating template configuration files..."
    
    # Get the list of config files
    local config_files=( $(get_config_file_list) )
    
    # Check each config file and create if missing
    for file in "${config_files[@]}"; do
        if [[ -f "configs/$file" ]]; then
            log_info "Config file $file already exists, skipping..."
            continue
        fi
        
        log_info "Creating template for $file..."
        case "$file" in
            "bashrc")
                cat > "configs/$file" << 'EOF'
#!/bin/bash
# ~/.bashrc - Server Configuration
# This file is managed by server-config setup script

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# History control
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend

# Check window size after commands
shopt -s checkwinsize

# Make less more friendly
export LESS="-R"

# Set default editor
export EDITOR=vim
export VISUAL=vim

# Set colored prompt
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Enable color support
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Some useful aliases
alias ll='ls -alh'
alias la='ls -A'
alias l='ls -CF'
alias h='history'
alias c='clear'
alias ..='cd ..'
alias ...='cd ../..'

# Source bash functions if available
if [ -f ~/.bash_functions ]; then
    . ~/.bash_functions
fi

# Add local bin directory to PATH
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
EOF
                ;;
            "vimrc")
                cat > "configs/$file" << 'EOF'
" ~/.vimrc - Server Configuration
" This file is managed by server-config setup script

" Use Vim settings, not Vi settings
set nocompatible

" Enable syntax highlighting
syntax on

" Show line numbers
set number

" Enable file type detection
filetype plugin indent on

" Indentation settings
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab

" Search settings
set incsearch
set hlsearch
set ignorecase
set smartcase

" Display settings
set ruler
set showcmd
set showmode
set wildmenu
set laststatus=2

" Disable backup and swap files
set nobackup
set nowritebackup
set noswapfile

" Key mappings
map <F5> :set paste!<CR>

" Status line
set statusline=%F%m%r%h%w\ [TYPE=%Y]\ [POS=%04l,%04v]\ [%p%%]\ [LEN=%L]

" Colorscheme settings
set background=dark
highlight Comment ctermfg=cyan
EOF
                ;;
            # Other templates are handled similarly
            *)
                log_info "Creating minimal template for $file"
                echo "# This is a template file for $file" > "configs/$file"
                echo "# Replace with your actual configuration" >> "configs/$file"
                ;;
        esac
        log_success "Created template for $file"
    done
}

# Get mapping of config files to their destination paths
get_config_destinations() {
    # Return mappings as file:destination pairs
    echo "bashrc:$HOME/.bashrc"
    echo "vimrc:$HOME/.vimrc"
    echo "tmux.conf:$HOME/.tmux.conf"
    echo "gitconfig:$HOME/.gitconfig"
    echo "screenrc:$HOME/.screenrc"
    echo "inputrc:$HOME/.inputrc"
    echo "ssh_config:$HOME/.ssh/config"
    echo "bash_functions:$HOME/.bash_functions"
    echo "gitignore_global:$HOME/.gitignore_global"
    echo "dircolors:$HOME/.dircolors"
}

# Install configuration files locally (not via web server)
install_local_config() {
    log_info "Installing configuration files from local directory..."
    
    # Create directory structure
    mkdir -p "$HOME/.ssh" "$HOME/.config/git"
    chmod 700 "$HOME/.ssh"
    
    # Check if configs directory exists
    if [[ ! -d "configs" ]]; then
        log_error "Configs directory not found. Run with --create-web-configs first."
        return 1
    fi
    
    # Parse the config destinations
    local config_map_str=$(get_config_destinations)
    
    # Process each config file
    while IFS=: read -r src dest; do
        local src_path="configs/$src"
        
        if [[ ! -f "$src_path" ]]; then
            log_error "Source file $src_path not found."
            continue
        fi
        
        if [[ -f "$dest" && $FORCE -eq 0 ]]; then
            log_warning "$dest already exists. Use --force to overwrite."
            continue
        fi
        
        # Backup existing file
        backup_file "$dest"
        
        # Create parent directory if it doesn't exist
        mkdir -p "$(dirname "$dest")"
        
        # Copy file with permissions handling
        if [[ "$src" == "ssh_config" ]]; then
            # Use sudo if needed for SSH config
            if ! cp "$src_path" "$dest" 2>/dev/null; then
                log_warning "Permission denied. You may need to run with sudo for the SSH config."
                log_warning "You can manually copy it later: cp configs/ssh_config $HOME/.ssh/config"
                log_warning "And set permissions: chmod 600 $HOME/.ssh/config"
                continue
            fi
            chmod 600 "$dest" 2>/dev/null || log_warning "Could not set permissions on $dest"
        else
            cp "$src_path" "$dest"
            chmod 644 "$dest" 2>/dev/null || log_warning "Could not set permissions on $dest"
        fi
        
        log_success "Installed $src to $dest"
    done <<< "$config_map_str"
    
    # Setup Git user name and email if gitconfig was installed
    if [[ -f "$HOME/.gitconfig" && -f "configs/gitconfig" ]]; then
        if grep -q "CHANGEME" "$HOME/.gitconfig"; then
            log_info "Setting up Git user configuration..."
            read -p "Enter your Git user name: " git_name
            read -p "Enter your Git email address: " git_email
            
            # Update the placeholders in the gitconfig
            sed -i "s/CHANGEME/$git_name/g" "$HOME/.gitconfig" 2>/dev/null || sed -i '' "s/CHANGEME/$git_name/g" "$HOME/.gitconfig"
            sed -i "s/CHANGEME@example.com/$git_email/g" "$HOME/.gitconfig" 2>/dev/null || sed -i '' "s/CHANGEME@example.com/$git_email/g" "$HOME/.gitconfig"
        fi
    fi
    
    log_success "Local configuration setup complete!"
    log_info "Backups of any existing files were stored in: $BACKUP_DIR"
    log_info "Log out and log back in to apply the new configurations."
}

# Create a specialized server setup script
create_server_setup_script() {
    log_info "Creating server setup script..."
    
    # Check if configs directory exists
    if [[ ! -d "configs" ]]; then
        log_error "Configs directory not found. Run with --create-web-configs first."
        return 1
    fi
    
    # Create the server setup script with proper shell escaping
    {
        echo '#!/bin/bash'
        echo '#'
        echo '# Server Setup Script'
        echo '# Description: Automatically configure a new Linux server with standard dotfiles'
        echo '# Generated by the server-config tool'
        echo ''
        echo 'set -e'
        echo ''
        echo 'CONFIG_URL="https://config.opope.dev/configs"'
        echo 'BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"'
        echo 'FORCE=0'
        echo ''
        echo '# Process arguments'
        echo 'if [[ "$1" == "--force" ]]; then'
        echo '    FORCE=1'
        echo 'fi'
        echo ''
        echo '# Color codes for output'
        echo 'RED='"'\033[0;31m'"
        echo 'GREEN='"'\033[0;32m'"
        echo 'YELLOW='"'\033[0;33m'"
        echo 'BLUE='"'\033[0;34m'"
        echo 'NC='"'\033[0m'" ' # No Color'
        echo ''
        echo '# Log helper functions'
        echo 'log_info() {'
        echo '    echo -e "${BLUE}[INFO]${NC} $1"'
        echo '}'
        echo ''
        echo 'log_success() {'
        echo '    echo -e "${GREEN}[SUCCESS]${NC} $1"'
        echo '}'
        echo ''
        echo 'log_warning() {'
        echo '    echo -e "${YELLOW}[WARNING]${NC} $1"'
        echo '}'
        echo ''
        echo 'log_error() {'
        echo '    echo -e "${RED}[ERROR]${NC} $1"'
        echo '}'
        echo ''
        echo '# Check if a command exists'
        echo 'command_exists() {'
        echo '    command -v "$1" >/dev/null 2>&1'
        echo '}'
        echo ''
        echo '# Backup an existing file'
        echo 'backup_file() {'
        echo '    local file="$1"'
        echo '    if [[ -f "$file" || -d "$file" ]]; then'
        echo '        mkdir -p "$BACKUP_DIR"'
        echo '        cp -a "$file" "$BACKUP_DIR/"'
        echo '        log_info "Backed up $file to $BACKUP_DIR/"'
        echo '    fi'
        echo '}'
        echo ''
        echo '# Download a configuration file'
        echo 'download_config() {'
        echo '    local file="$1"'
        echo '    local dest="$2"'
        echo '    '
        echo '    # Create parent directory if it doesn'\''t exist'
        echo '    mkdir -p "$(dirname "$dest")"'
        echo '    '
        echo '    if command_exists curl; then'
        echo '        curl -s "$CONFIG_URL/$file" -o "$dest"'
        echo '    elif command_exists wget; then'
        echo '        wget -q "$CONFIG_URL/$file" -O "$dest"'
        echo '    else'
        echo '        log_error "Neither curl nor wget is installed. Cannot download files."'
        echo '        exit 1'
        echo '    fi'
        echo '    '
        echo '    if [[ $? -ne 0 ]]; then'
        echo '        log_error "Failed to download $file"'
        echo '        return 1'
        echo '    fi'
        echo '    '
        echo '    chmod 644 "$dest"'
        echo '    log_success "Downloaded $file to $dest"'
        echo '    return 0'
        echo '}'
        echo ''
        
        # Add configuration file setup functions
        for config_file in $(get_config_file_list); do
            echo "# Setup function for $config_file"
            echo "setup_${config_file}() {"
            
            local dest_var
            case "$config_file" in
                "tmux.conf") dest_var='$HOME/.tmux.conf' ;;
                "ssh_config") dest_var='$HOME/.ssh/config' ;;
                *) dest_var='$HOME/.'$config_file ;;
            esac
            
            echo "    local dest=\"$dest_var\""
            echo '    if [[ -f "$dest" && $FORCE -eq 0 ]]; then'
            echo '        log_warning "$dest already exists. Use --force to overwrite."'
            echo '        return 1'
            echo '    fi'
            echo '    backup_file "$dest"'
            
            # Special handling for SSH config
            if [ "$config_file" = "ssh_config" ]; then
                echo '    mkdir -p "$HOME/.ssh"'
                echo '    chmod 700 "$HOME/.ssh"'
            fi
            
            echo "    download_config \"$config_file\" \"\$dest\""
            
            # Special handling for SSH config permissions
            if [ "$config_file" = "ssh_config" ]; then
                echo '    chmod 600 "$dest"'
            fi
            
            # Special handling for gitconfig
            if [ "$config_file" = "gitconfig" ]; then
                echo '    '
                echo '    # Prompt for git user configuration'
                echo '    read -p "Enter your Git user name: " git_name'
                echo '    read -p "Enter your Git email address: " git_email'
                echo '    '
                echo '    # Update the placeholders in the gitconfig'
                echo '    sed -i "s/CHANGEME/$git_name/g" "$dest" 2>/dev/null || sed -i '"'\'"' "s/CHANGEME/$git_name/g" "$dest"'
                echo '    sed -i "s/CHANGEME@example.com/$git_email/g" "$dest" 2>/dev/null || sed -i '"'\'"' "s/CHANGEME@example.com/$git_email/g" "$dest"'
            fi
            
            echo "}"
            echo ""
        done
        
        # Add main function
        echo "# Main script execution"
        echo "main() {"
        echo '    log_info "Starting server configuration setup..."'
        echo '    '
        echo '    # Check for required tools'
        echo '    if ! command_exists curl && ! command_exists wget; then'
        echo '        log_error "Neither curl nor wget is installed. Please install one of them first."'
        echo '        exit 1'
        echo '    fi'
        echo '    '
        echo '    # Setup configuration files'
        
        # Call setup functions for each config file
        for config_file in $(get_config_file_list); do
            echo "    setup_${config_file}"
        done
        
        echo '    '
        echo '    log_success "Configuration setup complete!"'
        echo '    log_info "Backups of any existing files were stored in: $BACKUP_DIR"'
        echo '    log_info "Log out and log back in to apply the new configurations."'
        echo "}"
        echo ""
        echo "# Run the main function"
        echo 'main "$@"'
    } > server_setup.sh
    
    chmod +x server_setup.sh
    
    # Copy to public directory for web access
    if [[ -d "public" ]]; then
        cp -f server_setup.sh public/
        log_info "Copied server_setup.sh to public directory for web access"
    fi
    
    log_success "Created server_setup.sh script"
    log_info "Upload this script to your server and run it to configure your server."
}

# Main script execution
main() {
    log_info "Starting server configuration setup..."
    
    # Check if we're creating web server configs
    if [[ $CREATE_WEB_CONFIGS -eq 1 ]]; then
        create_webserver_configs
        create_server_setup_script
        exit 0
    fi
    
    # Check if we're doing a local setup
    if [[ $LOCAL_SETUP -eq 1 ]]; then
        install_local_config
        exit 0
    fi
    
    # Check for required tools for remote setup
    if ! command_exists curl && ! command_exists wget; then
        log_error "Neither curl nor wget is installed. Please install one of them first."
        exit 1
    fi
    
    # Default behavior: setup configuration files from web server
    setup_bashrc
    setup_vimrc
    setup_tmux_conf
    setup_gitconfig
    setup_screenrc
    setup_inputrc
    setup_ssh_config
    setup_bash_functions
    setup_gitignore_global
    setup_dircolors
    
    log_success "Configuration setup complete!"
    log_info "Backups of any existing files were stored in: $BACKUP_DIR" 
    log_info "Log out and log back in to apply the new configurations."
}

# Run the main function
main "$@"