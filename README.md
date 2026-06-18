# Multi-Tenant Web Hosting with Isolated Client Environments on Azure

**Built by MaxwelCyber — GizmoFix Repair Services, Lagos, Nigeria**

A hands-on demonstration of hosting two clients (Emeka & Ebuka) on a single Azure Ubuntu VM with complete file-level isolation. Neither client can read, write, or execute the other's files — despite sharing the same server, same Nginx instance, and same operating system.

---

## Architecture Overview
┌──────────────────────────────────────────────────┐
│ Azure Ubuntu VM │
* │ │
│ ┌──────────────┐ ┌──────────────┐ │
│ │ Emeka (User) │ │ Ebuka (User) │ │
│ │ airtel group │ │ mtn group │ │
│ │ Port :8081 │ │ Port :8082 │ │
│ └──────┬───────┘ └──────┬───────┘ │
│ │ │ │
│ ┌──────▼──────────────┬───────▼──────────┐ │
│ │ /var/www/html-airtel│ /var/www/html-mtn│ │
│ │ Owner: emeka:airtel │ Owner: ebuka:mtn │ │
│ │ Perms: 750 (rwxr-x---)│ Perms: 750 │ │
│ └─────────────────────┴──────────────────┘ │
│ │ │
│ ┌───────▼────────┐ │
│ │ Nginx │ │
│ │ (www-data) │ │
│ │ Member of both │ │
│ │ airtel & mtn │ │
│ └────────────────┘ │
└──────────────────────────────────────────────────┘
