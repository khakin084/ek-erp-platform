# EK ERP Platform

This repository contains the **EK ERP distributed architecture**, built around a
**core service + headless microservices** model.

## 🧱 Project Layout
ek-erp-platform/
├─ docker-compose.yml
├─ .env
├─ .gitignore
├─ README.md
├─ prepare_repo.sh
│
├─ ek-core/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-auth/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-config/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-workflow/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-stakeholders/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-catalog/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-inventory/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-procurement/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-sales/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-production/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-logistics/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-billing/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-accounts/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-reporting/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-projects/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-hr/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
└─ ek-assets/
   ├─ src/.gitkeep
   └─ Dockerfile


## 🧱 Architecture Overview

- **ek-core-service**
  - Only public business entry point
  - Hosts the frontend
  - Acts as API gateway / BFF
  - Routes traffic to internal services

- **Headless domain services**
  - Business logic only
  - No public ports
  - Communicate via HTTP + event bus

- **Shared infrastructure**
  - PostgreSQL
  - Redis
  - RabbitMQ (event bus)
  - Consul (service registry)

---

## 📦 Services

### Core
- ek-core

### Platform
- ek-auth
- ek-config
- ek-workflow

### Master Data
- ek-stakeholders
- ek-catalog

### Operations
- ek-inventory
- ek-procurement
- ek-sales
- ek-production
- ek-logistics

### Finance
- ek-billing
- ek-accounts

### Supporting
- ek-reporting
- ek-projects
- ek-hr
- ek-assets

---

## 🗄 Databases

Each service owns its **own Postgres database**.

Databases are **auto-created at startup** using the `ek-db-init` container.

---

## 🚀 Getting Started

```bash
cp .env.example .env
docker compose up -d