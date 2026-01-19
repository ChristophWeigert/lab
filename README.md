# Hetzner Lab Infrastructure

Infrastructure as Code repository for managing a self-hosted homelab environment using Ansible for configuration management and Docker Compose for service orchestration.

## Overview

This project manages 20+ containerized services including media servers, home automation, authentication, monitoring, and productivity tools. All infrastructure is defined as code, version-controlled, and automated for repeatable deployments.

### Key Features

- **Infrastructure as Code**: All configurations in version control
- **Automated Deployment**: Ansible playbooks for server setup and maintenance
- **Containerized Services**: Docker Compose for service isolation and management
- **Reverse Proxy**: Traefik with automatic SSL/TLS certificates
- **Centralized Authentication**: Authentik SSO for supported services
- **Monitoring**: Uptime monitoring and metrics collection
- **CI/CD**: Automated linting via GitHub Actions

## Technology Stack

- **Configuration Management**: Ansible
- **Container Orchestration**: Docker & Docker Compose
- **Reverse Proxy**: Traefik
- **Operating System**: Ubuntu Server
- **CI/CD**: GitHub Actions

## Quick Start

### Prerequisites

- Ubuntu server (bare metal or VM)
- SSH access with sudo privileges
- Ansible installed on control machine
- Docker and Docker Compose on target hosts

### Initial Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd hetzner-lab
   ```

2. **Configure Ansible inventory:**
   ```bash
   # Edit your inventory file with target hosts
   vim inventory/hosts
   ```

3. **Install Docker on target hosts:**
   ```bash
   ansible-playbook ansible/installation/inst-docker-ubuntu.yaml
   ```

4. **Deploy services:**
   ```bash
   # Deploy individual services
   docker-compose -f docker/traefik/docker-compose.yaml up -d
   docker-compose -f docker/portainer/docker-compose.yaml up -d
   ```

## Project Structure

```
hetzner-lab/
├── ansible/                    # Ansible playbooks
│   ├── installation/          # Initial setup scripts
│   ├── maintenance/           # Maintenance tasks
│   ├── mailcow/              # Mailcow operations
│   └── update/               # Update playbooks
├── docker/                    # Docker Compose services
│   ├── traefik/              # Reverse proxy
│   ├── authentik/            # SSO & authentication
│   ├── jellyfin/             # Media server
│   ├── paperless-ngx/        # Document management
│   └── ...                   # 20+ other services
├── .github/
│   ├── instructions/         # Module-level AI Agent instructions
│   └── workflows/            # CI/CD workflows
├── .vscode/
│   └── tasks.json           # VS Code automation tasks
└── AGENTS.md                 # High-level project documentation
```

## Deployed Services

### Infrastructure
- **Traefik** - Reverse proxy and SSL/TLS management
- **Portainer** - Docker management UI
- **Cloudflared** - Cloudflare tunnel
- **Semaphore** - Ansible UI

### Authentication & Security
- **Authentik** - Identity provider and SSO
- **Vaultwarden** - Password manager

### Monitoring
- **Uptime Kuma** - Service uptime monitoring
- **InfluxDB** - Time-series database
- **Homepage** - Service dashboard

### Media
- **Jellyfin** - Media streaming server
- **Sonarr/Radarr/Prowlarr** - Media management (*arr stack)
- **Floatplane Downloader** - Content downloader

### Home Automation
- **ESPHome** - ESP device management
- **EVCC** - EV charging controller
- **Zigbee2MQTT** - Zigbee bridge
- **WMBusMeters** - Utility meter reader

### Productivity
- **Paperless-ngx** - Document management
- **Mealie** - Recipe manager
- **FreshRSS** - RSS aggregator
- **Ghost** - Blogging platform
- **Immich** - Photo backup and management
- **Dawarich** - Location tracking

### Communication
- **TeamSpeak** - Voice communication server

See [.github/instructions/services.instructions.md](.github/instructions/services.instructions.md) for detailed service documentation.

## Available Tasks

This project includes 18 VS Code tasks for common operations. Access them via Command Palette → "Tasks: Run Task".

### Ansible Tasks
- `ansible-lint-all` - Lint all playbooks
- `ansible-syntax-check` - Check playbook syntax
- `ansible-run-playbook` - Run specific playbook
- `ansible-install-docker` - Install Docker on Ubuntu
- `ansible-maintenance-apt` - System updates
- `ansible-maintenance-diskspace` - Check disk space
- `ansible-maintenance-reboot` - Check reboot requirements
- `ansible-mailcow-backup` - Backup mailcow
- `ansible-docker-cleanup` - Clean Docker resources

### Docker Tasks
- `docker-compose-validate` - Validate all compose files
- `docker-ps` - List running containers
- `docker-services-list` - List all services
- `docker-service-up` - Start a service
- `docker-service-down` - Stop a service
- `docker-service-restart` - Restart a service
- `docker-logs` - View service logs

### Validation Tasks
- `yaml-lint` - Lint all YAML files
- `validate-all` - Run all validation checks

## Common Operations

### Deploy a New Service

1. Create service directory:
   ```bash
   mkdir -p docker/myservice
   ```

2. Create `docker-compose.yaml` following the patterns in [.github/instructions/docker-compose.instructions.md](.github/instructions/docker-compose.instructions.md)

3. Validate configuration:
   ```bash
   docker-compose -f docker/myservice/docker-compose.yaml config
   ```

4. Deploy:
   ```bash
   docker-compose -f docker/myservice/docker-compose.yaml up -d
   ```

### Run Maintenance

Weekly maintenance routine:
```bash
# Check disk space
ansible-playbook ansible/maintenance/maint-diskspace.yaml

# Update packages
ansible-playbook ansible/update/upd-apt.yaml

# Check if reboot needed
ansible-playbook ansible/maintenance/maint-reboot-required.yaml
```

Monthly cleanup:
```bash
# Clean Docker resources
ansible-playbook ansible/maintenance/maint-docker-clean.yaml
```

### Update a Service

```bash
# Pull latest image
docker-compose -f docker/servicename/docker-compose.yaml pull

# Recreate container
docker-compose -f docker/servicename/docker-compose.yaml up -d

# Check logs
docker-compose -f docker/servicename/docker-compose.yaml logs -f
```

## Documentation

Comprehensive documentation is available for different aspects of the project:

- **[AGENTS.md](AGENTS.md)** - Project architecture and workflows
- **[Ansible Instructions](.github/instructions/ansible.instructions.md)** - Playbook patterns and best practices
- **[Docker Compose Instructions](.github/instructions/docker-compose.instructions.md)** - Service deployment patterns
- **[Maintenance Instructions](.github/instructions/maintenance.instructions.md)** - Operational procedures
- **[Services Catalog](.github/instructions/services.instructions.md)** - Complete service documentation

## Development Guidelines

### Ansible Playbooks

- Write idempotent playbooks (safe to run multiple times)
- Use descriptive task names
- Pass `ansible-lint` checks before committing
- Test with `--check` mode first
- See [ansible.instructions.md](.github/instructions/ansible.instructions.md) for details

### Docker Services

- One directory per service
- Use named volumes for persistent data
- Configure Traefik labels for web services
- Set restart policy to `unless-stopped`
- Validate with `docker-compose config`
- See [docker-compose.instructions.md](.github/instructions/docker-compose.instructions.md) for patterns

### Security

- Never commit secrets to repository
- Use Ansible Vault for sensitive data
- Use environment files (add to `.gitignore`)
- Implement proper network isolation
- Enable Authentik SSO where supported

## AI Agent Support

This project is configured for AI Agent assistance. Enable these VS Code settings:

- `github.copilot.chat.codeGeneration.useInstructionFiles` → `true`
- `chat.useAgentsMdFile` → `true`

## Validation

### Manual Validation

```bash
# Lint Ansible playbooks
ansible-lint ansible/

# Validate Docker Compose files
find docker/ -name 'docker-compose.y*ml' -exec docker-compose -f {} config -q \;

# Check Ansible syntax
find ansible/ -name '*.y*ml' -exec ansible-playbook --syntax-check {} \;
```

### CI/CD

GitHub Actions automatically runs `ansible-lint` on all pull requests and pushes to main branch.

## Backup Strategy

### Critical (Daily)
- Vaultwarden (passwords)
- Paperless-ngx (documents)
- Immich (photos)
- Authentik (user data)

### High Priority (Weekly)
- Jellyfin (library metadata)
- *arr stack (configurations)
- ESPHome (device configs)
- Zigbee2MQTT (device pairings)

See [maintenance.instructions.md](.github/instructions/maintenance.instructions.md) for complete backup strategy.

## Troubleshooting

### Service Not Accessible

1. Check Traefik labels in docker-compose.yaml
2. Verify service is on `traefik_proxy` network
3. Check Traefik logs: `docker logs traefik`
4. Verify DNS configuration

### Playbook Fails

1. Check inventory and connectivity: `ansible all -m ping`
2. Verify SSH access and sudo permissions
3. Run with verbose output: `ansible-playbook -vvv playbook.yaml`
4. Check syntax: `ansible-playbook --syntax-check playbook.yaml`

### High Disk Usage

1. Check usage: `ansible-playbook ansible/maintenance/maint-diskspace.yaml`
2. Clean Docker: `ansible-playbook ansible/maintenance/maint-docker-clean.yaml`
3. Review logs: `journalctl --vacuum-time=7d`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes following the project guidelines
4. Test changes locally
5. Run validation tasks
6. Submit a pull request

## License

[Specify your license here]

## Support

For issues and questions:
- Review documentation in `.github/instructions/`
- Check [AGENTS.md](AGENTS.md) for architectural guidance
- Consult service-specific documentation

---

**Note**: This is a self-hosted infrastructure project. Ensure proper security measures, regular backups, and monitoring are in place before deploying to production.
