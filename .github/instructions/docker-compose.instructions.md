# Docker Compose Instructions

This file provides guidance on working with Docker Compose files in the homelab project.

## Service Organization Pattern

Each service follows this isolation pattern:
- **One directory per service** under `docker/`
- **One docker-compose.yaml per service**
- Service-specific configuration files in the same directory
- Example structure:
  ```
  docker/
    servicename/
      docker-compose.yaml
      config/
      data/
  ```

## Naming Conventions

### Service Directories
- Use lowercase, hyphenated names
- Match common service names when possible
- Examples: `traefik`, `authentik`, `paperless-ngx`

### Container Names
- Format: `servicename` or `servicename-component`
- Examples: `traefik`, `authentik-server`, `authentik-worker`

### Networks
- Use descriptive names: `traefik_proxy`, `authentik_network`
- Create explicit networks for service isolation
- Connect to shared networks only when needed

### Volumes
- Named volumes: `servicename_data`, `servicename_config`
- Bind mounts: Use relative paths from compose file location
- Examples: `./config:/config`, `./data:/data`

## Common Patterns

### Basic Service Template

```yaml
version: "3.8"

services:
  servicename:
    image: service/image:tag
    container_name: servicename
    restart: unless-stopped
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Berlin
    volumes:
      - ./config:/config
      - servicename_data:/data
    networks:
      - traefik_proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.servicename.rule=Host(`servicename.example.com`)"
      - "traefik.http.services.servicename.loadbalancer.server.port=8080"

networks:
  traefik_proxy:
    external: true

volumes:
  servicename_data:
```

### Traefik Integration Pattern

Services exposed via Traefik should use these label patterns:

```yaml
labels:
  # Enable Traefik
  - "traefik.enable=true"
  
  # Router configuration
  - "traefik.http.routers.servicename.rule=Host(`servicename.example.com`)"
  - "traefik.http.routers.servicename.entrypoints=websecure"
  - "traefik.http.routers.servicename.tls=true"
  - "traefik.http.routers.servicename.tls.certresolver=letsencrypt"
  
  # Service configuration
  - "traefik.http.services.servicename.loadbalancer.server.port=8080"
  
  # Middleware (optional)
  - "traefik.http.routers.servicename.middlewares=authentik@docker"
```

### Environment Variables

Use environment files for cleaner compose files:

**docker-compose.yaml:**
```yaml
services:
  myservice:
    env_file:
      - stack.env
```

**stack.env:**
```env
PUID=1000
PGID=1000
TZ=Europe/Berlin
DB_HOST=database
```

### Health Checks

Add health checks for critical services:

```yaml
services:
  database:
    healthcheck:
      test: ["CMD", "pg_isready", "-U", "postgres"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

### Multi-Container Services

For services with multiple components (e.g., app + database):

```yaml
services:
  app:
    image: myapp:latest
    depends_on:
      database:
        condition: service_healthy
    environment:
      - DB_HOST=database
    networks:
      - app_network
      - traefik_proxy
  
  database:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD_FILE=/run/secrets/db_password
    volumes:
      - db_data:/var/lib/postgresql/data
    networks:
      - app_network
    healthcheck:
      test: ["CMD", "pg_isready"]

networks:
  app_network:
    internal: true
  traefik_proxy:
    external: true

volumes:
  db_data:
```

## Volume Management

### Named Volumes
- Preferred for application data
- Managed by Docker
- Backed up separately
- Example: `servicename_data:/app/data`

### Bind Mounts
- Use for configuration files
- Allows easy editing from host
- Use relative paths: `./config:/config`
- Be mindful of permissions

### Volume Permissions
```yaml
volumes:
  - ./config:/config
  - servicename_data:/data
environment:
  - PUID=1000  # User ID
  - PGID=1000  # Group ID
```

## Network Configuration

### Network Types

**Bridge (Default)**
- Services can communicate within the network
- Isolated from other networks

**External Networks**
- Shared across multiple compose files
- Used for Traefik proxy network
```yaml
networks:
  traefik_proxy:
    external: true
```

**Internal Networks**
- No external access
- For database/backend communication
```yaml
networks:
  backend:
    internal: true
```

### Port Mapping

**Exposed Ports (via Traefik)**
```yaml
# No ports section needed
labels:
  - "traefik.http.services.servicename.loadbalancer.server.port=8080"
```

**Direct Port Mapping (non-HTTP services)**
```yaml
ports:
  - "3306:3306"  # MySQL
  - "9987:9987/udp"  # TeamSpeak voice
```

## Restart Policies

Use consistent restart policies:

- **`unless-stopped`** - Default for most services (recommended)
- **`always`** - For critical infrastructure (Traefik, Portainer)
- **`on-failure`** - For one-time tasks or jobs
- **`no`** - For development/testing only

```yaml
restart: unless-stopped
```

## Security Best Practices

### Secrets Management

Never put secrets in compose files. Use:

1. **Environment files** (gitignored)
2. **Docker secrets**
3. **External secret managers**

```yaml
# Bad
environment:
  - DB_PASSWORD=mysecretpassword

# Good
env_file:
  - secrets.env  # In .gitignore
```

### User Permissions

Run containers as non-root when possible:

```yaml
user: "1000:1000"
# or
environment:
  - PUID=1000
  - PGID=1000
```

### Network Isolation

- Use internal networks for backend services
- Only expose necessary services to Traefik
- Limit port exposure

### Read-Only Root Filesystem

For security-critical services:

```yaml
read_only: true
tmpfs:
  - /tmp
  - /var/run
```

## Common Configuration Patterns

### Timezone Configuration

```yaml
environment:
  - TZ=Europe/Berlin
volumes:
  - /etc/localtime:/etc/localtime:ro
```

### Logging Configuration

```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### Resource Limits

```yaml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
    reservations:
      memory: 128M
```

## Validation and Testing

### Before Committing

1. **Validate syntax**: `docker-compose -f docker/servicename/docker-compose.yaml config`
2. **Check for errors**: Look for warnings in config output
3. **Test locally**: `docker-compose up -d` and verify functionality
4. **Check logs**: `docker-compose logs -f`

### VS Code Tasks

- **Validate all**: Run task `docker-compose-validate`
- **Start service**: Run task `docker-service-up`
- **Stop service**: Run task `docker-service-down`
- **View logs**: Run task `docker-logs`

### Common Validation Errors

**Invalid YAML syntax**
- Check indentation (use spaces, not tabs)
- Ensure proper quoting
- Verify array/map structure

**Missing required fields**
- Every service needs at least `image` or `build`
- Networks must be defined if referenced
- Volumes must be declared if named

**Network issues**
- External networks must exist before starting
- Service names must be unique across networks

## File Structure Example

**Complete docker-compose.yaml:**

```yaml
---
version: "3.8"

services:
  myservice:
    image: myorg/myservice:latest
    container_name: myservice
    restart: unless-stopped
    
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Berlin
    
    env_file:
      - stack.env
    
    volumes:
      - ./config:/config
      - myservice_data:/data
      - /etc/localtime:/etc/localtime:ro
    
    networks:
      - traefik_proxy
      - myservice_internal
    
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.myservice.rule=Host(`myservice.example.com`)"
      - "traefik.http.routers.myservice.entrypoints=websecure"
      - "traefik.http.routers.myservice.tls.certresolver=letsencrypt"
      - "traefik.http.services.myservice.loadbalancer.server.port=8080"
    
    depends_on:
      - database

  database:
    image: postgres:15-alpine
    container_name: myservice-db
    restart: unless-stopped
    
    environment:
      - POSTGRES_USER=myservice
      - POSTGRES_DB=myservice
    
    env_file:
      - db.env  # Contains POSTGRES_PASSWORD
    
    volumes:
      - db_data:/var/lib/postgresql/data
    
    networks:
      - myservice_internal
    
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U myservice"]
      interval: 10s
      timeout: 5s
      retries: 5

networks:
  traefik_proxy:
    external: true
  myservice_internal:
    internal: true

volumes:
  myservice_data:
  db_data:
```

## Updating Services

### Pulling New Images

```bash
docker-compose -f docker/servicename/docker-compose.yaml pull
docker-compose -f docker/servicename/docker-compose.yaml up -d
```

### Checking for Updates

Use Watchtower or manually check image tags:
```bash
docker images | grep servicename
```

### Rolling Back

```bash
docker-compose -f docker/servicename/docker-compose.yaml down
# Edit docker-compose.yaml to use previous tag
docker-compose -f docker/servicename/docker-compose.yaml up -d
```

## Troubleshooting

### Service Won't Start

1. Check logs: `docker-compose logs servicename`
2. Validate config: `docker-compose config`
3. Check port conflicts: `docker ps`
4. Verify volumes exist and have correct permissions
5. Check network connectivity

### Traefik Not Routing

1. Verify Traefik labels are correct
2. Check service is on `traefik_proxy` network
3. Verify port in loadbalancer matches container port
4. Check Traefik logs: `docker logs traefik`
5. Ensure DNS points to correct IP

### Permission Issues

1. Check PUID/PGID match host user
2. Verify volume ownership on host
3. Check container user with `docker exec servicename id`

## Best Practices Summary

1. ✅ One service per directory with its own compose file
2. ✅ Use named volumes for persistent data
3. ✅ Set restart policy to `unless-stopped`
4. ✅ Configure Traefik labels for web services
5. ✅ Use health checks for critical services
6. ✅ Isolate services with networks
7. ✅ Never commit secrets to repository
8. ✅ Validate with `docker-compose config`
9. ✅ Use environment files for configuration
10. ✅ Document service-specific settings
