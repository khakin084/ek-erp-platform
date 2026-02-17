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
├─ ek-core-service/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-auth-service/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-config-service/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-workflow-service/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-stakeholders-service/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-catalog-service/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-inventory-service/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-procurement-service/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-sales-service/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-production-service/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-logistics-service/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-billing-service/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-accounts-service/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-reporting-service/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-projects-service/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
├─ ek-hr-service/
│  ├─ src/.gitkeep
│  └─ Dockerfile
│
└─ ek-assets-service/
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
- ek-core-service

### Platform
- ek-auth-service
- ek-config-service
- ek-workflow-service

### Master Data
- ek-stakeholders-service
- ek-catalog-service

### Operations
- ek-inventory-service
- ek-procurement-service
- ek-sales-service
- ek-production-service
- ek-logistics-service

### Finance
- ek-billing-service
- ek-accounts-service

### Supporting
- ek-reporting-service
- ek-projects-service
- ek-hr-service
- ek-assets-service

---

## 🗄 Databases

Each service owns its **own Postgres database**.

Databases are **auto-created at startup** using the `ek-db-init` container.

---

## 🚀 Getting Started

```bash
cp .env.example .env
docker compose up -d