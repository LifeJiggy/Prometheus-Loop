# Security Policy

## Supported Versions

| Version | Supported |
|---|---|
| 1.0.x | Yes |
| < 1.0 | No |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly.

### How to Report

1. **Do NOT** open a public GitHub issue
2. Email: security@prometheus-loop.dev
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- **Acknowledgment**: Within 48 hours
- **Assessment**: Within 1 week
- **Resolution**: Within 30 days for critical issues
- **Credit**: You will be credited in the changelog (unless you prefer anonymity)

## Security Measures

### Code Security

- All dependencies are scanned for vulnerabilities
- Code is reviewed before merging
- Secrets are never committed to the repository

### Plugin Security

- Plugin signatures are verified
- Plugins run in sandboxed environments
- Plugin permissions are explicitly declared

### Data Security

- No user data is collected without consent
- All data transmission is encrypted
- Sensitive data is never logged

## Security Updates

Security updates are released as soon as possible. Subscribe to security advisories on GitHub for notifications.

## Past Vulnerabilities

No known vulnerabilities at this time.
