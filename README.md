# Multi-Tenant Web Hosting with Isolated Client Environments

**Built by Maxwell — Lagos, Nigeria**

A production-ready demonstration of hosting multiple clients on a single Azure VM with full file-level isolation using Linux permissions and Nginx.

---

## Architecture Overview

┌─────────────────────────────────────────────────┐
│ Azure Ubuntu VM │
│ │
│ ┌──────────────┐ ┌──────────────┐ │
│ │ Emeka (A) │ │ Ebuka (B) │ │
│ │ airtel grp │ │ mtn group │ │
│ │ :8081 │ │ :8082 │ │
│ └──────┬───────┘ └──────┬───────┘ │
│ │ │ │
│ ┌──────▼───────────────┬───▼───────────┐ │
│ │ /var/www/html-airtel │ /var/www/html-mtn │ │
│ │ Owner: emeka:airtel │ Owner: ebuka:mtn │ │
│ │ Perms: 750 │ Perms: 750 │ │
│ └──────────────────────┴────────────────┘ │
│ │
│ ┌──────────────┐ │
│ │ Nginx │ │
│ │ (www-data) │ │
│ │ in airtel │ │
│ │ in mtn │ │
│ └──────────────┘ │
└─────────────────────────────────────────────────┘


## Key Security Features

| Feature | Implementation |
|---------|---------------|
| **Client Isolation** | Separate Linux users and groups per client |
| **File Permissions** | `chmod 750` — owner rwx, group rx, others nothing |
| **Web Server Access** | Nginx (`www-data`) added to each client's group |
| **Cross-Client Protection** | Client A cannot read Client B's files |
| **No 777 Anywhere** | Least privilege enforced throughout |

## Tech Stack

- **Cloud:** Microsoft Azure
- **OS:** Ubuntu 22.04 LTS
- **Web Server:** Nginx
- **Access Control:** Linux users, groups, `chown`, `chmod` (octal 4/2/1)

## Quick Deploy

```bash
git clone <this-repo>
cd multi-tenant-azure-project
chmod +x setup.sh
sudo ./setup.sh
