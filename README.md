# Multi-Tenant Web Hosting with Isolated Client Environments on Azure

**Built by MaxwelCyber — GizmoFix Repair Services, Lagos, Nigeria**

A hands-on demonstration of hosting two clients (Emeka & Ebuka) on a single Azure Ubuntu VM with complete file-level isolation. Neither client can read, write, or execute the other's files — despite sharing the same server, same Nginx instance, and same operating system.

---

## Architecture Overview
┌──────────────────────────────────────────────────┐
│ Azure Ubuntu VM │
│ │
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


## How It Works

- **Each client is a Linux user** with their own group (`emeka:airtel`, `ebuka:mtn`)
- **File permissions set to 750** (`chmod 750`) — owner gets full control (7), group gets read & execute (5), others get **nothing** (0)
- **Nginx runs as `www-data`** — added to *both* `airtel` and `mtn` groups so it can serve both sites through the group permission slot
- **Others (0) remains locked** — neither client can access the other's files because they're not in each other's group and "others" is set to zero
- **The `-R` (recursive) flag** ensures every file and subdirectory inside each client's web root inherits the same 750 permission — no accidental loopholes

## Verifying Isolation (Screenshots)

| Test | Expected Result |
|------|----------------|
| Browser loads `http://<VM-IP>:8081` | Airtel page shown |
| Browser loads `http://<VM-IP>:8082` | MTN page shown |
| `emeka` runs `cat /var/www/html-mtn/index.html` | **Permission denied** |
| `ebuka` runs `cat /var/www/html-airtel/index.html` | **Permission denied** |

![Airtel Site](images/airtel-site.png)
![MTN Site](images/mtn-site.png)
![Permission Denied](images/permission-denied.png)

## Key Security Features

| Feature | Implementation |
|---------|---------------|
| **Client Isolation** | Separate Linux users and groups per client |
| **File Permissions** | `chmod 750` — owner rwx, group rx, others nothing |
| **Web Server Access** | Nginx (`www-data`) added to each client's group via `usermod -aG` |
| **Cross-Client Protection** | Client A cannot read, write, or execute Client B's files |
| **Recursive Enforcement** | `-R` flag ensures no file or folder escapes the permission rules |
| **No 777 Anywhere** | Least privilege enforced throughout |

## Lessons Learned

### 1. `chmod` and the 4/2/1 Octal System
Every permission in Linux boils down to three numbers: **owner**, **group**, **others** — each calculated by adding read (4), write (2), and execute (1). `750` means:
- Owner: 4+2+1 = 7 (full control)
- Group: 4+0+1 = 5 (read + execute)
- Others: 0+0+0 = 0 (nothing)

### 2. The Power of `-R` (Recursive)
Without `-R`, `chmod` only hits the top-level directory. Files inside could retain looser permissions — a silent backdoor. Always use `-R` when securing an entire web root.

### 3. The "2" Special Flag — Write Permission
Granting write (2) to group or others is how sites get defaced. In this setup, only the owner gets write — the web server (`www-data`) gets read and execute only. Even if Nginx is compromised, the attacker can't modify files.

### 4. Group Membership > Opening "Others"
Instead of `chmod 757` (dangerous), we added `www-data` to each client's group. Nginx reads through the **group** permission slot, so "others" stays locked at zero. Both sites are served, neither client is exposed.

### 5. Two Users, One Server, Zero Cross-Access
Emeka and Ebuka share the same VM, same CPU, same Nginx — but Emeka cannot touch Ebuka's files and vice versa. This is the foundation of multi-tenant cloud hosting and IAM role design.

### 6. Azure NSG Rules Matter
When ports 8081 and 8082 didn't respond, the issue wasn't Nginx — it was Azure's Network Security Group blocking inbound traffic. Always check the cloud firewall before blaming the application.

## Tech Stack

- **Cloud:** Microsoft Azure (Ubuntu 22.04 LTS VM)
- **Web Server:** Nginx
- **Access Control:** Linux users, groups, `chown`, `chmod` (octal notation)
- **Scripting:** Bash (full deployment script included)

## Quick Deploy

```bash
git clone https://github.com/maxwelcyber/Multi-Tenant-Web-Hosting-with-Isolated-Client-Environments-on-Azure.git
cd multi-tenant-azure-project
chmod +x setup.sh
sudo ./setup.sh
