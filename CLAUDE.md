# CLAUDE.md - Server Configuration Repository

## Commands
- Run server setup: `./setup_server.sh`
- Force server setup (overwrite existing configs): `./setup_server.sh --force`
- Create web server config files: `./setup_server.sh --create-web-configs`
- Lint bash scripts: `shellcheck setup_server.sh`

## Code Style Guidelines
- **Shell Scripting**: Use bash for scripts with proper shebang (`#!/bin/bash`)
- **Error Handling**: Use `set -e` to exit on error, provide helpful error messages
- **Logging**: Use color-coded output functions (log_info, log_success, log_warning, log_error)
- **Functions**: Create reusable functions with descriptive names and local variables
- **Naming Convention**: Use snake_case for variables and functions
- **Comments**: Document all functions with a brief description of purpose
- **Conditional Logic**: Use double brackets for conditions `[[ ... ]]`
- **Backup Strategy**: Always backup existing files before modification
- **Security**: Set proper file permissions (chmod 600 for SSH configs, 644 for others)