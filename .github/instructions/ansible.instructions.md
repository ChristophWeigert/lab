# Ansible Playbook Instructions

This file provides guidance on working with Ansible playbooks in the homelab project.

## Playbook Organization

Playbooks are organized by function in the `ansible/` directory:

- **`installation/`** - Initial server setup and software installation
- **`mailcow/`** - Mailcow-specific operations (backup, updates)
- **`maintenance/`** - Regular maintenance tasks
- **`update/`** - System and application updates

## Naming Conventions

### Playbook Files
- Use descriptive, hyphenated names
- Prefix indicates category: `inst-`, `maint-`, `upd-`
- Use `.yaml` extension (not `.yml`)
- Examples:
  - `inst-docker-ubuntu.yaml`
  - `maint-diskspace.yaml`
  - `upd-apt.yaml`

### Tasks
- Use descriptive names that explain what the task does (not how)
- Start with a verb when possible
- Examples:
  - "Install Docker packages"
  - "Check disk space usage"
  - "Update APT cache"

### Variables
- Use lowercase with underscores: `docker_version`, `backup_path`
- Prefix with service/context: `mailcow_backup_dir`, `docker_compose_version`
- Document purpose in comments or vars files

### Handlers
- Name handlers clearly: "Restart Docker service", "Reload systemd"
- Place handlers in handlers section or separate handlers file
- Ensure idempotence - handlers should be safe to run multiple times

## Common Modules Used

The project commonly uses these Ansible modules:

- **`apt`** - Package management (install, update, remove)
- **`docker_container`** - Manage Docker containers
- **`docker_compose`** - Manage Docker Compose services
- **`file`** - Create/manage files and directories
- **`copy`** - Copy files to remote hosts
- **`template`** - Process Jinja2 templates
- **`service`** - Manage system services
- **`systemd`** - Systemd-specific operations
- **`command`** / **`shell`** - Run commands (use sparingly)
- **`stat`** - Get file/directory information
- **`lineinfile`** - Modify specific lines in files

## Idempotence Requirements

All playbooks MUST be idempotent - running them multiple times should:
- Produce the same result
- Not cause errors
- Show "ok" or "changed" status accurately

### Ensuring Idempotence

- Use modules' built-in idempotence (apt, file, copy, etc.)
- Check state before making changes
- Use `creates` or `removes` parameters with command/shell
- Use `changed_when` to control when tasks report changes
- Test by running playbook twice - second run should show minimal changes

Example:
```yaml
- name: Create directory
  file:
    path: /opt/myapp
    state: directory
    owner: root
    group: root
    mode: '0755'
  # This is idempotent - safe to run multiple times
```

## Error Handling Patterns

### Check Mode Support
- Test playbooks with `--check` flag before applying
- Use `check_mode: false` for tasks that must run even in check mode

### Ignore Errors Carefully
```yaml
- name: Task that might fail
  command: some_command
  ignore_errors: true
  register: result
  
- name: Take action based on result
  debug:
    msg: "Command failed, but continuing"
  when: result.failed
```

### Conditional Execution
```yaml
- name: Check if file exists
  stat:
    path: /etc/myconfig
  register: config_file

- name: Create config if missing
  copy:
    src: default.conf
    dest: /etc/myconfig
  when: not config_file.stat.exists
```

### Failed When
```yaml
- name: Run command
  command: my_command
  register: result
  failed_when: 
    - result.rc != 0
    - '"acceptable error" not in result.stderr'
```

## Ansible-Lint Compliance

All playbooks must pass `ansible-lint` checks:

### Running ansible-lint
- Use VS Code task: `ansible-lint-all`
- Command line: `ansible-lint ansible/`
- CI/CD: Automatically runs on push/pull requests

### Common Rules

- **`yaml[line-length]`** - Keep lines under 160 characters
- **`name[casing]`** - Task names should be descriptive sentences
- **`no-changed-when`** - Use `changed_when` with command/shell modules
- **`package-latest`** - Avoid `state: latest`, specify versions
- **`risky-shell-pipe`** - Prefer modules over shell pipes
- **`fqcn[action]`** - Use fully qualified collection names (e.g., `ansible.builtin.apt`)

### Disabling Rules
Only disable rules when absolutely necessary, with justification:
```yaml
# noqa: yaml[line-length]
- name: This task has a very long name that explains exactly what it does
```

## Variable Management

### Variable Precedence
- Use appropriate variable scope (playbook, role, host, group)
- Document where variables are defined
- Use `defaults/` for default values
- Use `vars/` for required values

### Secrets
- Never commit secrets to repository
- Use Ansible Vault for sensitive data:
  ```bash
  ansible-vault create secrets.yml
  ansible-vault edit secrets.yml
  ansible-playbook --ask-vault-pass playbook.yaml
  ```

## Inventory Management

### Host Organization
- Define hosts in inventory files
- Group hosts logically (webservers, databases, etc.)
- Use group_vars and host_vars for configuration

### Connection Settings
- Use SSH keys, not passwords
- Configure ansible.cfg for SSH settings
- Test connectivity: `ansible all -m ping`

## Tags for Selective Execution

Use tags to run specific parts of playbooks:

```yaml
- name: Install packages
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - docker
    - docker-compose
  tags:
    - install
    - docker
```

Run with tags:
```bash
ansible-playbook playbook.yaml --tags "install"
ansible-playbook playbook.yaml --skip-tags "docker"
```

## Testing Playbooks

### Before Committing

1. **Syntax check**: Run task `ansible-syntax-check`
2. **Lint check**: Run task `ansible-lint-all`
3. **Dry run**: `ansible-playbook --check playbook.yaml`
4. **Run on test host**: Apply to non-production first
5. **Verify idempotence**: Run twice, check for unnecessary changes

### During Development

- Use `-v`, `-vv`, or `-vvv` for verbose output
- Use `--step` to execute tasks one at a time
- Use `--start-at-task` to resume from a specific task
- Use `debug` module to print variable values

## Playbook Structure Template

```yaml
---
# Brief description of what this playbook does
- name: Descriptive playbook name
  hosts: target_hosts
  become: true  # If sudo is needed
  
  vars:
    # Playbook-specific variables
    my_var: value
  
  tasks:
    - name: First task description
      ansible.builtin.apt:
        name: package_name
        state: present
      tags:
        - install
    
    - name: Second task description
      ansible.builtin.service:
        name: service_name
        state: started
        enabled: true
      tags:
        - configure
  
  handlers:
    - name: Restart service
      ansible.builtin.service:
        name: service_name
        state: restarted
```

## VS Code Task Integration

Access playbooks through VS Code tasks:

- **Run specific playbook**: Use task `ansible-run-playbook` (prompts for path)
- **Pre-defined tasks**: Use category-specific tasks like `ansible-install-docker`
- **Validation**: Use `ansible-lint-all` and `ansible-syntax-check`

See [AGENTS.md](../../AGENTS.md) for complete task list.

## Best Practices Summary

1. ✅ Write idempotent playbooks
2. ✅ Use descriptive task names
3. ✅ Pass ansible-lint checks
4. ✅ Test with --check before applying
5. ✅ Use modules instead of command/shell when possible
6. ✅ Document variables and their purpose
7. ✅ Use Ansible Vault for secrets
8. ✅ Tag tasks appropriately
9. ✅ Handle errors gracefully
10. ✅ Verify by running twice
