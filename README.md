# 🔐 EOSSL

<div align="center">

### Professional SSL Certificate Manager for Linux Servers

![Version](https://img.shields.io/badge/Version-v1.0-blue)
![Bash](https://img.shields.io/badge/Bash-Script-green)
![Linux](https://img.shields.io/badge/Linux-Supported-orange)
![Cloudflare](https://img.shields.io/badge/Cloudflare-API-F38020)
![Let's Encrypt](https://img.shields.io/badge/Let'sEncrypt-Supported-003A70)
![acme.sh](https://img.shields.io/badge/acme.sh-Supported-success)
![Certbot](https://img.shields.io/badge/Certbot-Supported-brightgreen)
![License](https://img.shields.io/badge/License-MIT-yellow)

Issue • Renew • Revoke • Wildcard • Cloudflare API • Panel Deployment

</div>

---

# 🚀 Overview

**EOSSL** is a lightweight and powerful SSL/TLS certificate management utility designed for Linux servers.

It simplifies issuing, renewing, revoking and deploying SSL certificates using **acme.sh** and **Certbot**, while providing built-in support for **Cloudflare DNS API** and popular panels such as **Marzban**, **3x-ui**, **x-ui**, **s-ui** and **Hiddify**.

---

# ✨ Features

* 🔐 Single Domain SSL Certificates
* ⭐ Wildcard SSL Certificates
* 🌍 Multi-Domain SSL Certificates
* ☁️ Cloudflare DNS API Integration
* 🔄 Certificate Renewal
* ❌ Certificate Revocation
* 📂 Custom Certificate Installation Path
* 🚀 Automatic Deployment To Panels
* 🔁 acme.sh → Certbot Fallback
* 🧹 Complete Uninstall Option
* 🐧 Supports Most Linux Distributions

---

# 🛠 Installation

Run as root:

```bash
sudo bash -c "$(curl -sL https://raw.githubusercontent.com/EOAMIR/EOSSL/main/eossl.sh)"
```

Alternative CDN:

```bash
sudo bash -c "$(curl -sL https://raw.githack.com/EOAMIR/EOSSL/main/eossl.sh)"
```

> 💡 The second link uses a CDN and may work better on some networks.

---

# 🚀 Usage

Launch EOSSL:

```bash
eossl
```

---

# 🖥 Main Menu

```text
1 ─ Issue SSL Certificate
2 ─ Renew SSL Certificate
3 ─ Revoke SSL Certificate
4 ─ Uninstall EOSSL
5 ─ Exit
```

---

# 📜 Supported Certificate Types

### 1️⃣ Single Domain

Example:

```text
sub.domain.com
```

Required:

```text
Domain
Email Address
```

---

### 2️⃣ Wildcard SSL

Example:

```text
*.domain.com
```

Supported Methods:

```text
Manual DNS Verification
Cloudflare API Verification
```

Required:

```text
Domain
Email Address
```

Cloudflare Mode:

```text
Cloudflare Email
Cloudflare Global API Key
```

---

### 3️⃣ Multi-Domain SSL

Example:

```text
sub1.domain1.com sub2.domain2.com sub3.domain3.com
```

Required:

```text
Domains
Email Address
```

---

# ☁️ Cloudflare API Mode

EOSSL can automatically verify domains using Cloudflare DNS API.

Required Information:

```text
Cloudflare Email
Cloudflare Global API Key
Domain Name
```

Benefits:

* No manual TXT records
* Faster issuance
* Fully automated wildcard certificates
* No DNS interruptions

Cloudflare API Documentation:

https://developers.cloudflare.com/fundamentals/api/get-started/keys/

---

# 📂 Certificate Deployment

Certificates can be automatically deployed to:

| Destination                   | Path                               |
| ----------------------------- | ---------------------------------- |
| Custom Directory              | User Defined                       |
| Marzban                       | `/var/lib/marzban/certs/<domain>/` |
| 3x-ui / x-ui / s-ui / Hiddify | `/certs/<domain>/`                 |

---

# 📦 Generated Files

```text
fullchain.cer
cert.cer
ca.cer
privkey.key
```

---

# 🔄 Certificate Renewal

Enter:

```text
sub.domain.com
```

or

```text
*.domain.com
```

EOSSL will automatically check whether renewal is required.

---

# ❌ Certificate Revocation

Enter the target domain and EOSSL will revoke the certificate safely.

---

# 🧹 Uninstall

EOSSL can remove:

```text
acme.sh
certbot
socat
dependencies
```

Optionally remove all issued certificates.

---

# 🔄 Certificate Workflow

```text
Select Domain
      │
      ▼
Choose Validation Method
      │
      ▼
Verify Domain
      │
      ▼
Issue Certificate
      │
      ▼
Select Deployment Path
      │
      ▼
Deploy Files
      │
      ▼
Done
```

---

# 🐧 Supported Operating Systems

| Distribution | Status |
| ------------ | ------ |
| Ubuntu       | ✅      |
| Debian       | ✅      |
| CentOS       | ✅      |
| AlmaLinux    | ✅      |
| Rocky Linux  | ✅      |
| Fedora       | ✅      |
| Arch Linux   | ✅      |

---

# ⚠️ Requirements

* Root Access
* Linux Server
* Valid Domain
* DNS Pointed To Server
* Port 80 Available (Standalone Mode)

---

# 📞 Contact

* Telegram: https://t.me/EOAMIRM
* GitHub: https://github.com/EOAMIR

---

### ❤️ Support The Project

If EOSSL helps you, please consider giving the repository a ⭐ on GitHub.

---

<sub><sub>Developed by EOAMIR</sub></sub>
