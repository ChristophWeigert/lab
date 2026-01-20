# Maintenance Operations Instructions

This file provides guidance on maintenance playbooks and regular operational tasks for the hetzner-lab infrastructure.

## Available Maintenance Playbooks

### Disk Space Monitoring (`maint-diskspace.yaml`)

**Purpose:** Check disk space usage on managed hosts

**When to Run:**
- Weekly as part of routine maintenance
- Before deploying new services
- When experiencing performance issues
- After large data operations

**VS Code Task:** `ansible-maintenance-diskspace`

**What It Does:**
- Checks filesystem usage across all managed hosts
- Reports partitions with high usage
- Alerts if thresholds are exceeded

**Expected Output:**
- Disk usage percentages per filesystem
- Warnings for filesystems >80% full
- Critical alerts for filesystems >90% full

**Follow-up Actions:**
- If high usage detected, run `ansible-docker-cleanup`
- Review log files: `/var/log/*`
- Check for large files: `du -sh /* | sort -h`
- Consider expanding storage or removing old data

---

### Docker Cleanup (`maint-docker-clean.yaml`)

**Purpose:** Clean up unused Docker resources to reclaim disk space

**When to Run:**
- Monthly as routine maintenance
- When disk space is running low
- After major service updates
- Before taking backups

**VS Code Task:** `ansible-docker-cleanup`

**What It Does:**
- Removes stopped containers
- Deletes unused images
- Cleans up dangling volumes
- Prunes build cache
- Removes unused networks

**Equivalent Manual Commands:**
```bash
docker container prune -f
docker image prune -a -f
docker volume prune -f
docker network prune -f
docker builder prune -f
```

**Expected Results:**
- Reclaimed disk space (amount varies)
- Removal of orphaned resources
- Faster Docker operations

**Caution:**
- Does NOT remove running containers or their images
- Does NOT remove named volumes in use
- Safe to run, but review output for unexpected removals

---

### Reboot Required Check (`maint-reboot-required.yaml`)

**Purpose:** Check if system reboot is needed after updates

**When to Run:**
- After running APT updates
- Weekly as part of routine checks
- Before planned maintenance windows
- After kernel or security updates

**VS Code Task:** `ansible-maintenance-reboot`

**What It Does:**
- Checks for `/var/run/reboot-required` file
- Reports which hosts need rebooting
- Lists reasons for reboot requirement
- Does NOT automatically reboot

**Expected Output:**
- List of hosts requiring reboot
- Packages/updates that triggered the requirement
- Usually kernel updates, systemd, or core libraries

**Follow-up Actions:**
1. Plan maintenance window
2. Notify users of downtime
3. Stop non-critical services gracefully
4. Reboot affected hosts: `ansible -a "reboot" target_hosts`
5. Verify services restart properly

**When to Reboot:**
- During planned maintenance windows
- For critical security updates (promptly)
- For kernel updates (at next convenient time)
- For library updates (when convenient)

---

### APT Package Updates (`upd-apt.yaml`)

**Purpose:** Update system packages on Ubuntu hosts

**When to Run:**
- Weekly for security updates
- Monthly for general updates
- Immediately for critical security patches
- Before major service deployments

**VS Code Task:** `ansible-maintenance-apt`

**What It Does:**
- Updates APT package cache
- Upgrades installed packages
- Removes unnecessary dependencies
- Cleans package cache

**Equivalent Manual Commands:**
```bash
apt update
apt upgrade -y
apt autoremove -y
apt autoclean
```

**Expected Duration:**
- Cache update: 10-30 seconds
- Package upgrade: 2-10 minutes (varies by updates)
- Total: 5-15 minutes typically

**Post-Update Actions:**
1. Run `ansible-maintenance-reboot` to check reboot needs
2. Verify critical services are running
3. Check for held packages: `apt-mark showhold`
4. Review update logs for errors

**Caution:**
- May require system reboot (check afterwards)
- Can cause service restarts (systemd, networking)
- Test on non-production first if possible

---

## Maintenance Schedules

### Daily Tasks
- Monitor service health (Uptime Kuma)
- Check critical alerts
- Review backup status

### Weekly Tasks
1. **Disk Space Check**: `ansible-maintenance-diskspace`
2. **APT Updates**: `ansible-maintenance-apt`
3. **Reboot Check**: `ansible-maintenance-reboot`
4. **Docker Stats**: `docker stats --no-stream`

### Monthly Tasks
1. **Docker Cleanup**: `ansible-docker-cleanup`
2. **Log Rotation Check**: Verify logs are being rotated
3. **Certificate Expiry**: Check SSL/TLS certificates (Traefik)
4. **Backup Verification**: Test restore from backups

### Quarterly Tasks
1. **Service Audit**: Review all running services
2. **Dependency Updates**: Update Docker images
3. **Security Audit**: Review access logs and permissions
4. **Documentation Review**: Update configs and docs

### Annual Tasks
1. **Infrastructure Review**: Assess resource needs
2. **Disaster Recovery Test**: Full backup/restore test
3. **Access Review**: Audit user accounts and permissions

---

## Maintenance Workflows

### Routine Weekly Maintenance

**Total time:** ~20-30 minutes

```bash
# 1. Check disk space
ansible-playbook ansible/maintenance/maint-diskspace.yaml

# 2. Update packages
ansible-playbook ansible/update/upd-apt.yaml

# 3. Check if reboot needed
ansible-playbook ansible/maintenance/maint-reboot-required.yaml

# 4. Plan reboot if needed (schedule separately)

# 5. Verify services
docker ps
```

### Monthly Deep Clean

**Total time:** ~45-60 minutes

```bash
# 1. Disk space before
ansible-playbook ansible/maintenance/maint-diskspace.yaml

# 2. Docker cleanup
ansible-playbook ansible/maintenance/maint-docker-clean.yaml

# 3. Update packages
ansible-playbook ansible/update/upd-apt.yaml

# 4. Disk space after (compare)
ansible-playbook ansible/maintenance/maint-diskspace.yaml

# 5. Reboot check
ansible-playbook ansible/maintenance/maint-reboot-required.yaml

# 6. Update Docker images
cd docker/
for dir in */; do
  docker-compose -f "$dir/docker-compose.yaml" pull
done

# 7. Restart updated services
# (Do selectively based on updates)
```

### Emergency Disk Space Recovery

**When disk is critically full:**

```bash
# 1. Immediate Docker cleanup
ansible-playbook ansible/maintenance/maint-docker-clean.yaml

# 2. Clear logs (if needed)
# On affected host:
journalctl --vacuum-time=7d
find /var/log -type f -name "*.log" -mtime +30 -delete

# 3. Check for large files
du -ah / | sort -rh | head -20

# 4. Remove old backups (if applicable)
# Review and remove manually

# 5. Verify space recovered
df -h
```

---

## Monitoring and Alerts

### Disk Space Thresholds

- **Normal**: < 70% used (no action)
- **Warning**: 70-80% used (plan cleanup)
- **Alert**: 80-90% used (run cleanup soon)
- **Critical**: > 90% used (immediate action)

### Service Health Checks

**Verify services are running:**
```bash
docker ps
docker-compose -f docker/servicename/docker-compose.yaml ps
```

**Check logs for errors:**
```bash
docker logs --tail 50 container_name
journalctl -u docker -n 50
```

### Resource Usage Monitoring

**Check Docker resource usage:**
```bash
docker stats --no-stream
docker system df
```

**Check system resources:**
```bash
free -h
top
htop
```

---

## Backup Considerations

### Mailcow Backup

**Purpose:** Backup mailcow data and configuration

**VS Code Task:** `ansible-mailcow-backup`

**When to Run:**
- Before mailcow updates
- Weekly as part of backup routine
- Before major configuration changes

**What It Backs Up:**
- Mail data
- Configuration files
- Database
- Certificates

### General Backup Strategy

**What to Backup:**
- Docker volumes (named volumes with data)
- Service configurations (`./config` directories)
- Environment files (`.env`, `stack.env`)
- Traefik configurations and certificates
- Database dumps

**Backup Frequency:**
- **Critical services** (mail, passwords): Daily
- **Important services** (photos, documents): Daily
- **Standard services**: Weekly
- **Configuration files**: On change

**Backup Retention:**
- Daily: Keep 7 days
- Weekly: Keep 4 weeks
- Monthly: Keep 12 months
- Yearly: Keep indefinitely (or per policy)

---

## Troubleshooting Maintenance Issues

### Playbook Fails to Run

**Check inventory:**
```bash
ansible-inventory --list
```

**Check connectivity:**
```bash
ansible all -m ping
```

**Verify SSH access:**
```bash
ssh user@host
```

### Disk Cleanup Not Freeing Space

1. Check if space is actually freed: `df -h`
2. Look for large files: `du -sh /var/lib/docker/*`
3. Check if files are held open: `lsof | grep deleted`
4. Restart Docker daemon: `systemctl restart docker`

### Updates Cause Service Failures

1. Check service logs: `docker logs container_name`
2. Verify configuration: `docker-compose config`
3. Check for breaking changes in image updates
4. Rollback to previous image version if needed
5. Test updates on non-production first

### Cannot Reboot (Services Required)

1. Identify critical services that must stay up
2. Schedule reboot during low-usage period
3. Notify users of planned downtime
4. Consider live kernel patching for critical systems
5. Use rolling reboots for redundant services

---

## Best Practices

1. ✅ Run maintenance during low-traffic periods
2. ✅ Always check disk space before major operations
3. ✅ Review playbook output for errors or warnings
4. ✅ Test on non-production environments first
5. ✅ Document any manual interventions required
6. ✅ Keep maintenance logs for audit trail
7. ✅ Schedule regular maintenance windows
8. ✅ Notify users of planned downtime
9. ✅ Verify services after maintenance
10. ✅ Have rollback plans for updates

## Quick Reference

| Task | VS Code Command | Frequency |
|------|----------------|-----------|
| Disk Space Check | `ansible-maintenance-diskspace` | Weekly |
| Docker Cleanup | `ansible-docker-cleanup` | Monthly |
| Reboot Check | `ansible-maintenance-reboot` | After Updates |
| APT Updates | `ansible-maintenance-apt` | Weekly |
| Mailcow Backup | `ansible-mailcow-backup` | Weekly |
