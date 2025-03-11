# Server Configuration

A simple, modern, and extensible configuration manager for Linux/Unix servers.

## Overview

This project provides a framework for managing server configurations in a modular way. It helps you:

- Maintain consistent configurations across multiple servers
- Easily deploy configurations to new servers
- Keep your configuration files organized and version controlled
- Provide a smooth onboarding experience for new team members

## Directory Structure

```
server-config/
├── configs/           # Configuration files
│   ├── bashrc
│   ├── vimrc
│   ├── tmux.conf
│   └── ...
├── setup_server.sh    # Main setup script
├── README.md          # Documentation
└── CLAUDE.md          # CLI helper information
```

## Usage

### Creating Configuration Files

To set up your configuration files:

```bash
./setup_server.sh --create-web-configs
```

This will:
1. Check if all required configuration files exist in the `configs/` directory
2. Offer to create template files for any missing configurations
3. Generate a standalone server setup script that can be deployed to servers

### Local Installation

To install configurations on your local machine:

```bash
./setup_server.sh --local
```

This will copy configuration files from the `configs/` directory to their appropriate locations in your home directory.

### Remote Server Installation

After creating your configurations, you have two options for server deployment:

#### Option 1: Host the configs on a web server

1. Upload the `configs/` directory to your web server
2. Update the `CONFIG_URL` in `setup_server.sh` to point to the URL where configs are hosted
3. Run the script on your server:

```bash
./setup_server.sh
```

#### Option 1a: Using Cloudflare Pages (Recommended)

This project is optimized for deployment with Cloudflare Pages, which provides free hosting with SSL:

1. Initialize a git repository if you haven't already:
   ```bash
   git init
   git add configs/ setup_server.sh README.md
   git commit -m "Initial commit"
   ```

2. Create a new GitHub repository and push your code:
   ```bash
   git remote add origin https://github.com/yourusername/server-config.git
   git branch -M main
   git push -u origin main
   ```

3. Set up a Cloudflare Pages project:
   - Sign up for a [Cloudflare account](https://dash.cloudflare.com/sign-up)
   - Go to the Pages section and click "Create a project"
   - Connect your GitHub account and select your server-config repository
   - Configure the build settings:
     - Build command: Leave empty
     - Build output directory: `public`
     - Root directory: `/`
   - The `_headers` file ensures config files are served as plain text
   - Deploy the site

4. After deployment, your configs will be available at `https://yourproject.pages.dev/configs/`
5. Update the `CONFIG_URL` in the script to point to your Cloudflare Pages URL
6. Regenerate the server_setup.sh file with `./setup_server.sh --create-web-configs`

##### Setting up a Custom Domain

To use a custom domain like `config.example.com`:

1. In Cloudflare Pages, go to your project settings
2. Click on "Custom domains" and add your domain (e.g., `config.example.com`)
3. Follow the DNS configuration instructions
4. After setup, update the `CONFIG_URL` in your script to use your custom domain
5. Regenerate the server setup script with your new URL

#### Option 2: Use the generated standalone script

1. After running `--create-web-configs`, you'll have a `server_setup.sh` file
2. Transfer this script to your server
3. Run it on your server:

```bash
./server_setup.sh
```

### Forcing Installation

To overwrite existing configuration files, use the `--force` flag:

```bash
./setup_server.sh --force
```

## Configuration Files

The following configuration files are supported:

| File | Description | Destination |
|------|-------------|------------|
| bashrc | Bash shell configuration | ~/.bashrc |
| vimrc | Vim editor settings | ~/.vimrc |
| tmux.conf | Tmux terminal multiplexer config | ~/.tmux.conf |
| gitconfig | Git configuration | ~/.gitconfig |
| screenrc | GNU Screen configuration | ~/.screenrc |
| inputrc | Readline configuration | ~/.inputrc |
| ssh_config | SSH client configuration | ~/.ssh/config |
| bash_functions | Custom bash functions | ~/.bash_functions |
| gitignore_global | Global Git ignore rules | ~/.gitignore_global |
| dircolors | Terminal color settings | ~/.dircolors |

## Customization

To customize the configurations:

1. Edit the files in the `configs/` directory to your liking
2. Run the setup script with the appropriate flags

## Security

- SSH configuration files are installed with 600 permissions (user read/write only)
- All other configuration files use 644 permissions (user read/write, others read-only)
- Existing configuration files are backed up before being overwritten

## Web Server Configuration

When using Cloudflare Pages (or any web server):

- The `_headers` file in the `public` directory sets the `Content-Type: text/plain` header for all files
- This ensures that configuration files are displayed as plain text in the browser, not downloaded
- The web interface at the root URL provides an easy way to browse available configuration files

## License

MIT License