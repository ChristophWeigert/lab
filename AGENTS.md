# Home Lab Infrastructure Project

## Project Overview

Infrastructure as Code repository for managing a self-hosted and cloud-hosted (Mailcow) homelab environment using Ansible for configuration management and Docker Compose for service orchestration.

## Application Architecture

### Architectural Patterns

- **Infrastructure as Code (IaC)**: All infrastructure defined in version-controlled files
- **Declarative Configuration**: Docker Compose and Ansible playbooks define desired state
- **Service-Oriented Architecture**: Microservices running in isolated containers
- **Reverse Proxy Pattern**: Traefik as central ingress controller

### Design Principles

- **Idempotence**: Ansible playbooks can be run multiple times safely
- **Separation of Concerns**: Each service has its own docker-compose.yaml
- **Maintainability**: Clear directory structure (ansible/, docker/)
- **Automation**: GitHub Actions for linting, Ansible for deployment

### Technology Stack

- **Configuration Management**: Ansible playbooks
- **Container Orchestration**: Docker Compose
- **Reverse Proxy**: Traefik
- **CI/CD**: GitHub Actions
- **Host OS**: Ubuntu (based on playbooks)

### Project Structure

#### Ansible Directory (`ansible/`)

- `installation/`: Initial server setup playbooks
  - `inst-docker-ubuntu.yaml`: Docker installation on Ubuntu
  - `inst-vm-core.yaml`: Core VM setup
- `mailcow/`: Mailcow-specific operations
  - `mailcow-backup.yaml`: Backup mailcow data
  - `update.yaml`: Update mailcow installation
- `maintenance/`: Regular maintenance tasks
  - `maint-diskspace.yaml`: Monitor disk space usage
  - `maint-docker-clean.yaml`: Clean up Docker resources
  - `maint-reboot-required.yaml`: Check if system reboot is needed
- `update/`: Update playbooks
  - `upd-apt.yaml`: System package updates

#### Docker Directory (`docker/`)

Each subdirectory contains a service with its own `docker-compose.yaml`:

**Media Services**
- `arrs/`: Media management suite (Sonarr, Radarr, etc.)
- `jellyfin/`: Media streaming server
- `floatplane-downloader/`: Floatplane content downloader

**Authentication & Security**
- `authentik/`: Identity provider and SSO
- `vaultwarden/`: Password manager

**Monitoring & Management**
- `uptimekuma/`: Uptime monitoring
- `influxdb/`: Time-series database
- `homepage/`: Dashboard
- `portainer/`: Docker management UI

**Infrastructure Services**
- `traefik/`: Reverse proxy and load balancer
- `cloudflared/`: Cloudflare tunnel
- `semaphore/`: Ansible UI

**Home Automation**
- `esphome/`: ESP device management
- `evcc/`: EV charging controller
- `zigbee2mqtt/`: Zigbee bridge
- `wmbusmeters/`: Wireless M-Bus meter reader

**Productivity & Communication**
- `paperless-ngx/`: Document management
- `mealie/`: Recipe manager
- `freshrss/`: RSS aggregator
- `ghost/`: Blogging platform

**Other Services**
- `immich/`: Photo management
- `dawarich/`: Location tracking
- `teamspeak/`: Voice communication

## Testing Strategy

### Validation Types

1. **Ansible Linting**: ansible-lint for playbook best practices
2. **YAML Validation**: Syntax checking for all YAML files
3. **Docker Compose Validation**: `docker-compose config` for each service
4. **Syntax Checking**: ansible-playbook --syntax-check

### Running Tests

Use VS Code tasks for validation:
- **Lint Ansible**: Run task `ansible-lint-all`
- **Check Syntax**: Run task `ansible-syntax-check`
- **Validate Docker Compose**: Run task `docker-compose-validate`
- **Full Validation**: Run task `validate-all`
- **CI/CD**: GitHub Actions runs ansible-lint automatically on push/PR

## Common Workflows

### Adding a New Docker Service

1. Create directory under `docker/[service-name]/`
2. Add `docker-compose.yaml` following existing patterns
3. Configure Traefik labels if web-accessible
4. Document service purpose and configuration
5. Test with: `docker-compose -f docker/[service-name]/docker-compose.yaml config`
6. Deploy with task `docker-service-up`

### Modifying Ansible Playbooks

1. Edit playbook in appropriate `ansible/` subdirectory
2. Run task `ansible-lint-all` to check compliance
3. Test with `ansible-playbook --check [playbook-path]` (dry-run mode)
4. Run playbook on target hosts
5. Verify idempotence by running again - should show no changes

### Running Maintenance Operations

Use pre-built VS Code tasks:
- **Disk Space Check**: `ansible-maintenance-diskspace`
- **Docker Cleanup**: `ansible-docker-cleanup`
- **APT Updates**: `ansible-maintenance-apt`
- **Reboot Check**: `ansible-maintenance-reboot`

### Managing Docker Services

Use VS Code tasks for common operations:
- **List Services**: `docker-services-list`
- **Start Service**: `docker-service-up` (prompts for service name)
- **Stop Service**: `docker-service-down`
- **Restart Service**: `docker-service-restart`
- **View Logs**: `docker-logs`
- **Check Running**: `docker-ps`

## Security Considerations

- **Secrets Management**: Use Ansible Vault for sensitive data
- **Network Isolation**: Docker networks per service or service group
- **Reverse Proxy**: Traefik handles SSL/TLS termination
- **Authentication**: Authentik provides SSO where possible
- **Credentials**: Never commit passwords, API keys, or tokens to repository
- **Access Control**: Traefik middleware for authentication and authorization

## Development Guidelines

### General Principles

- Follow existing directory structure and naming conventions
- Use YAML for all configuration files (consistent formatting)
- Document complex configurations with inline comments
- Keep services isolated - one directory per service
- Use meaningful names for services, tasks, and variables

### Ansible Best Practices

- Write idempotent playbooks (can be run multiple times safely)
- Use descriptive task names (what the task does, not how)
- Group related tasks logically
- Use variables for values that might change
- Tag tasks appropriately for selective execution
- Test with `--check` mode before applying
- Run `ansible-lint` before committing

### Docker Compose Best Practices

- Use named volumes for persistent data
- Define networks explicitly when needed
- Set restart policies (`unless-stopped` is common)
- Configure health checks for critical services
- Use environment variables for configuration
- Document port mappings and their purpose
- Add Traefik labels following existing patterns
- Validate with `docker-compose config` before deployment

### File Organization

- **Ansible playbooks**: Organize by function (installation, maintenance, updates)
- **Docker services**: One directory per service with its own compose file
- **Documentation**: Keep README.md updated, use inline comments
- **Configuration**: Separate configuration from secrets

### Version Control

- Commit frequently with descriptive messages
- Use `.gitignore` for secrets and local files
- Test changes locally before pushing
- GitHub Actions will validate Ansible playbooks automatically

## Available VS Code Tasks

Quick reference for automation tasks:

**Ansible Operations**
- `ansible-lint-all` - Lint all Ansible playbooks
- `ansible-syntax-check` - Check playbook syntax
- `ansible-run-playbook` - Run a specific playbook (prompts for path)
- `ansible-install-docker` - Install Docker on Ubuntu
- `ansible-maintenance-apt` - Run system updates
- `ansible-maintenance-diskspace` - Check disk space
- `ansible-maintenance-reboot` - Check if reboot needed
- `ansible-mailcow-backup` - Backup mailcow
- `ansible-docker-cleanup` - Clean Docker resources

**Docker Operations**
- `docker-compose-validate` - Validate all compose files
- `docker-ps` - List running containers
- `docker-services-list` - List all available services
- `docker-service-up` - Start a service (prompts for name)
- `docker-service-down` - Stop a service (prompts for name)
- `docker-service-restart` - Restart a service (prompts for name)
- `docker-logs` - View service logs (prompts for name)

**Validation**
- `yaml-lint` - Lint all YAML files
- `validate-all` - Run all validation checks

## Troubleshooting

### Common Issues

**Ansible playbook fails**
- Check inventory and host connectivity
- Verify SSH access and sudo permissions
- Run with `-vvv` flag for verbose output
- Check for syntax errors with `ansible-syntax-check`

**Docker service won't start**
- Check logs with `docker-logs` task
- Validate compose file with `docker-compose-validate`
- Verify port conflicts with `docker-ps`
- Check volume permissions and disk space

**Traefik routing issues**
- Verify service labels are correct
- Check Traefik logs
- Ensure DNS points to correct IP
- Verify network configuration

### Getting Help

- Review service-specific instructions in `.github/instructions/`
- Check existing configurations in similar services
- Use VS Code tasks for common operations
- Consult service documentation for specific issues
