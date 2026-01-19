# Services Catalog and Instructions

This file documents all deployed services in the hetzner-lab infrastructure, their purposes, and management guidelines.

## Service Categories

### Infrastructure Services

#### Traefik (`docker/traefik/`)
**Purpose:** Reverse proxy and load balancer  
**Access:** Central ingress point for all web services  
**Key Features:**
- Automatic SSL/TLS certificate management (Let's Encrypt)
- Dynamic service discovery via Docker labels
- Middleware support (auth, rate limiting, headers)
- HTTP/HTTPS routing based on hostnames

**Dependencies:** Required by most web services  
**Backup Priority:** High (configuration and certificates)  
**Update Notes:** Test routing after updates

---

#### Portainer (`docker/portainer/`)
**Purpose:** Docker management UI  
**Access:** Web interface for Docker administration  
**Key Features:**
- Container management (start, stop, restart, logs)
- Image management and registry integration
- Volume and network management
- User access control

**Dependencies:** Docker daemon  
**Backup Priority:** Medium (user configurations)  
**Update Notes:** May require re-login after updates

---

#### Cloudflared (`docker/cloudflared/`)
**Purpose:** Cloudflare tunnel for secure remote access  
**Access:** Provides secure tunnel without exposing ports  
**Key Features:**
- Zero-trust network access
- No inbound firewall rules needed
- Automatic failover and load balancing
- TLS encryption by default

**Dependencies:** Cloudflare account and tunnel configuration  
**Backup Priority:** High (tunnel credentials)  
**Update Notes:** Check tunnel status after updates

---

#### Semaphore (`docker/semaphore/`)
**Purpose:** Ansible UI and automation platform  
**Access:** Web interface for running Ansible playbooks  
**Key Features:**
- Visual playbook execution
- Scheduled automation
- Execution history and logs
- Team collaboration

**Dependencies:** Ansible playbooks  
**Backup Priority:** High (project configurations)  
**Update Notes:** Database migrations may be required

---

### Authentication & Security

#### Authentik (`docker/authentik/`)
**Purpose:** Identity provider and SSO  
**Access:** Centralized authentication for services  
**Key Features:**
- Single sign-on (SSO)
- LDAP and SAML support
- Multi-factor authentication (MFA)
- User and group management
- OAuth2/OIDC provider

**Dependencies:** Database (usually PostgreSQL)  
**Backup Priority:** Critical (user data and configurations)  
**Update Notes:** Test SSO integrations after major updates  
**Architecture:** Multi-container (server + worker)

---

#### Vaultwarden (`docker/vaultwarden/`)
**Purpose:** Password manager (Bitwarden-compatible)  
**Access:** Web, mobile, and browser extensions  
**Key Features:**
- Encrypted password storage
- Password sharing and organization
- Two-factor authentication support
- Emergency access
- Secure note storage

**Dependencies:** None (standalone)  
**Backup Priority:** Critical (encrypted vault data)  
**Update Notes:** Export vault before major updates  
**Security:** Ensure strong master password and 2FA

---

### Monitoring & Management

#### Uptime Kuma (`docker/uptimekuma/`)
**Purpose:** Uptime and status monitoring  
**Access:** Web dashboard  
**Key Features:**
- Service health monitoring
- HTTP/TCP/Ping checks
- Status pages
- Notifications (multiple channels)
- Response time tracking

**Dependencies:** None  
**Backup Priority:** Medium (monitoring configuration)  
**Update Notes:** Check notification integrations

---

#### InfluxDB (`docker/influxdb/`)
**Purpose:** Time-series database  
**Access:** API and web UI  
**Key Features:**
- High-performance time-series data storage
- Metrics and analytics
- Data retention policies
- Integration with monitoring tools

**Dependencies:** None  
**Backup Priority:** High (depends on data criticality)  
**Update Notes:** Database schema changes may require migration  
**Used By:** Home automation metrics, monitoring data

---

#### Homepage (`docker/homepage/`)
**Purpose:** Application dashboard  
**Access:** Web interface  
**Key Features:**
- Service status overview
- Quick links to all services
- Widget integration (weather, calendar, etc.)
- Customizable layout
- Service health indicators

**Dependencies:** None (reads from other services)  
**Backup Priority:** Low (configuration only)  
**Update Notes:** Check widget integrations

---

### Media Services

#### Jellyfin (`docker/jellyfin/`)
**Purpose:** Media streaming server  
**Access:** Web, mobile, TV apps  
**Key Features:**
- Movie and TV show library
- Music streaming
- Live TV and DVR
- Hardware transcoding
- Multi-user support

**Dependencies:** Media storage  
**Backup Priority:** High (library metadata and user data)  
**Update Notes:** Test transcoding after updates  
**Storage:** Requires large storage for media files

---

#### Arrs Suite (`docker/arrs/`)
**Purpose:** Media management automation  
**Services Included:**
- **Sonarr:** TV show management
- **Radarr:** Movie management
- **Prowlarr:** Indexer manager
- **Bazarr:** Subtitle management

**Key Features:**
- Automatic media organization
- Quality upgrades
- Calendar and scheduling
- Integration with download clients

**Dependencies:** Download clients, Jellyfin  
**Backup Priority:** High (configuration and database)  
**Update Notes:** Test integrations after updates

---

#### Floatplane Downloader (`docker/floatplane-downloader/`)
**Purpose:** Download Floatplane content  
**Access:** Configuration-based  
**Key Features:**
- Automated content downloading
- Quality selection
- Channel subscriptions

**Dependencies:** Storage for downloads  
**Backup Priority:** Low (re-configurable)  
**Update Notes:** Check download paths and credentials

---

### Home Automation

#### ESPHome (`docker/esphome/`)
**Purpose:** ESP device firmware management  
**Access:** Web interface  
**Key Features:**
- ESP32/ESP8266 device configuration
- YAML-based device definitions
- OTA firmware updates
- Home Assistant integration

**Dependencies:** ESP devices on network  
**Backup Priority:** High (device configurations)  
**Update Notes:** Test device connections after updates

---

#### EVCC (`docker/evcc/`)
**Purpose:** EV charging controller  
**Access:** Web interface  
**Key Features:**
- Electric vehicle charging management
- Solar power integration
- Smart charging schedules
- Energy cost optimization
- Multiple charger support

**Dependencies:** EV charger hardware  
**Backup Priority:** Medium (configuration)  
**Update Notes:** Test charger communication

---

#### Zigbee2MQTT (`docker/zigbee2mqtt/`)
**Purpose:** Zigbee device bridge to MQTT  
**Access:** Web interface  
**Key Features:**
- Zigbee device pairing and management
- MQTT message publishing
- Device firmware updates
- Network visualization
- Home Assistant integration

**Dependencies:** Zigbee USB adapter, MQTT broker  
**Backup Priority:** High (device pairings)  
**Update Notes:** Backup coordinator backup before updates  
**Hardware:** Requires Zigbee coordinator

---

#### WMBusMeters (`docker/wmbusmeters/`)
**Purpose:** Wireless M-Bus meter reader  
**Access:** Configuration-based  
**Key Features:**
- Smart meter reading (water, gas, electricity)
- MQTT publishing
- Multiple meter support

**Dependencies:** wMBus receiver hardware  
**Backup Priority:** Medium (meter configurations)  
**Hardware:** Requires wMBus USB receiver

---

### Productivity & Communication

#### Paperless-ngx (`docker/paperless-ngx/`)
**Purpose:** Document management system  
**Access:** Web interface  
**Key Features:**
- Document scanning and OCR
- Automatic tagging and organization
- Full-text search
- Email integration for document import
- Workflow automation

**Dependencies:** Database, Redis  
**Backup Priority:** Critical (documents and metadata)  
**Update Notes:** Database migrations may be required  
**Architecture:** Multi-container (web + worker + database)

---

#### Mealie (`docker/mealie/`)
**Purpose:** Recipe manager and meal planner  
**Access:** Web interface and mobile app  
**Key Features:**
- Recipe import from URLs
- Meal planning and calendars
- Shopping list generation
- Recipe sharing
- Nutritional information

**Dependencies:** Database  
**Backup Priority:** Medium (recipes and meal plans)  
**Update Notes:** Export recipes before major updates

---

#### FreshRSS (`docker/freshrss/`)
**Purpose:** RSS feed aggregator  
**Access:** Web interface  
**Key Features:**
- Feed management and organization
- Article reading and archiving
- Mobile app integration
- Share to services
- Customizable themes

**Dependencies:** Database  
**Backup Priority:** Medium (feed configurations and read status)  
**Update Notes:** Check feed fetching after updates

---

#### Ghost (`docker/ghost/`)
**Purpose:** Blogging and publishing platform  
**Access:** Web interface  
**Key Features:**
- Modern content editor
- SEO optimization
- Newsletter functionality
- Membership and subscriptions
- Custom themes

**Dependencies:** Database (MySQL/MariaDB)  
**Backup Priority:** Critical (posts and configuration)  
**Update Notes:** Test themes and integrations after updates  
**Architecture:** May include database container

---

### Photo & Location

#### Immich (`docker/immich/`)
**Purpose:** Photo and video backup and management  
**Access:** Web interface and mobile apps  
**Key Features:**
- Automatic mobile photo backup
- Facial recognition
- Location tagging
- Album organization
- Sharing capabilities
- Machine learning features

**Dependencies:** Database, Redis, Machine Learning container  
**Backup Priority:** Critical (photos and metadata)  
**Update Notes:** Database migrations common, check compatibility  
**Architecture:** Multi-container (server, ML, web, etc.)  
**Storage:** Requires significant storage

---

#### Dawarich (`docker/dawarich/`)
**Purpose:** Location tracking and history  
**Access:** Web interface  
**Key Features:**
- GPS location tracking
- Timeline visualization
- Import from various sources
- Privacy-focused self-hosted solution

**Dependencies:** Database  
**Backup Priority:** High (location history)  
**Update Notes:** Check data import/export functionality

---

### Communication

#### TeamSpeak (`docker/teamspeak/`)
**Purpose:** Voice communication server  
**Access:** TeamSpeak client  
**Key Features:**
- Voice chat channels
- File sharing
- Permissions and groups
- Low latency
- Self-hosted voice solution

**Dependencies:** None  
**Backup Priority:** Medium (server configuration and permissions)  
**Update Notes:** Test client connectivity  
**Ports:** Requires UDP and TCP ports

---

## Service Dependencies

### Critical Dependencies

**Traefik is required by:**
- All web-accessible services (Authentik, Jellyfin, Portainer, etc.)

**Authentik can provide SSO for:**
- Traefik
- Jellyfin
- Paperless-ngx
- Homepage
- Other services supporting OIDC/SAML

**Database services needed by:**
- Authentik (PostgreSQL)
- Paperless-ngx (PostgreSQL)
- Immich (PostgreSQL)
- FreshRSS (MySQL/PostgreSQL)
- Ghost (MySQL/MariaDB)
- Mealie (PostgreSQL/SQLite)

### Network Dependencies

**Services on traefik_proxy network:**
- All web services requiring reverse proxy

**Internal networks:**
- Database containers (isolated from Traefik)
- Service-specific backend networks

---

## Common Service Operations

### Starting a Service

Using VS Code task:
```
Run task: docker-service-up
Enter service name: jellyfin
```

Manual command:
```bash
docker-compose -f docker/jellyfin/docker-compose.yaml up -d
```

### Stopping a Service

Using VS Code task:
```
Run task: docker-service-down
Enter service name: jellyfin
```

### Viewing Logs

Using VS Code task:
```
Run task: docker-logs
Enter service name: jellyfin
```

### Updating a Service

```bash
# Pull latest image
docker-compose -f docker/servicename/docker-compose.yaml pull

# Recreate container with new image
docker-compose -f docker/servicename/docker-compose.yaml up -d

# Check logs for issues
docker-compose -f docker/servicename/docker-compose.yaml logs -f
```

### Backing Up a Service

**Volume-based backup:**
```bash
# Stop service
docker-compose -f docker/servicename/docker-compose.yaml down

# Backup volumes
docker run --rm -v servicename_data:/data -v $(pwd):/backup \
  alpine tar czf /backup/servicename-backup.tar.gz /data

# Restart service
docker-compose -f docker/servicename/docker-compose.yaml up -d
```

---

## Backup Priority Guide

### Critical (Daily Backups)
- Vaultwarden (passwords)
- Paperless-ngx (documents)
- Immich (photos)
- Authentik (user data)

### High (Weekly Backups)
- Jellyfin (library metadata)
- Arrs (configurations)
- ESPHome (device configs)
- Zigbee2MQTT (device pairings)
- Traefik (certificates and config)
- Semaphore (automation configs)

### Medium (Monthly Backups)
- FreshRSS (feed subscriptions)
- Mealie (recipes)
- InfluxDB (depends on data importance)
- Homepage (dashboard config)
- Dawarich (location history)

### Low (On-Change or Optional)
- Uptime Kuma (monitoring config)
- Floatplane Downloader (re-configurable)
- TeamSpeak (can be reconfigured)

---

## Update Strategy

### Safe to Update Frequently
- Homepage
- Uptime Kuma
- Portainer
- Cloudflared

### Update with Testing
- Traefik (test routing after)
- Jellyfin (test playback and transcoding)
- Arrs suite (test integrations)
- ESPHome (test device connectivity)

### Update Carefully
- Authentik (test SSO integrations)
- Vaultwarden (export vault first)
- Paperless-ngx (database migrations)
- Immich (frequent breaking changes)
- Zigbee2MQTT (coordinator backup first)

### Monitor After Updates
- Check service logs for errors
- Verify web interface accessibility
- Test core functionality
- Check integrations with other services
- Monitor resource usage

---

## Troubleshooting Common Issues

### Service Not Accessible via Traefik

1. Check Traefik labels in docker-compose.yaml
2. Verify service is on traefik_proxy network
3. Check Traefik logs: `docker logs traefik`
4. Verify DNS points to server IP
5. Check certificate status in Traefik dashboard

### Service Won't Start

1. Check logs: `docker-compose logs servicename`
2. Validate compose file: `docker-compose config`
3. Check port conflicts: `docker ps`
4. Verify volume permissions
5. Check available disk space

### High Resource Usage

1. Check with: `docker stats`
2. Review service-specific logs
3. Check for transcoding (Jellyfin)
4. Check for ML processing (Immich)
5. Review container resource limits

### Data Loss Prevention

1. Regular backups (see backup priorities)
2. Test restore procedures
3. Use named volumes (managed by Docker)
4. Document volume locations
5. Version control for configurations

---

## Best Practices

1. ✅ One service per directory structure
2. ✅ Use Traefik for all web services
3. ✅ Implement proper backup strategy by priority
4. ✅ Test updates on less critical services first
5. ✅ Monitor logs after changes
6. ✅ Document service-specific configurations
7. ✅ Use Authentik SSO where supported
8. ✅ Regular security updates
9. ✅ Monitor resource usage
10. ✅ Keep service documentation current
