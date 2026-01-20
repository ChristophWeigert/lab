# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this homelab infrastructure project, please report it responsibly:

1. **DO NOT** open a public GitHub issue
2. Email the repository maintainer directly with details
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if available)

I will acknowledge receipt within 48 hours and provide a detailed response within 7 days.

## Known Limitations

This is a **homelab environment**. Security considerations include:

- Self-hosted services may have undiscovered vulnerabilitie
- Configuration is optimized for convenience over enterprise-grade security
- Some services may expose administrative interfaces on the local network
- This setup is intended for personal use

## Dependency Updates

- **Renovate**: Automated dependency updates are configured via `renovate.json`
- Review and merge Renovate PRs promptly for security updates

## Compliance

This project does not claim compliance with any specific security standards (SOC2, ISO 27001, etc.). It follows general security best practices for homelab environments.

## Additional Resources

- [Docker Security Best Practices](https://docs.docker.com/engine/security/)
- [Ansible Security Automation](https://www.ansible.com/use-cases/security-automation)
- [Traefik Security Documentation](https://doc.traefik.io/traefik/https/overview/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

---

**Last Updated**: February 4, 2026
