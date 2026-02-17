# 3️⃣ `prepare_repo.sh`

This is your **one-command bootstrap script**, adapted cleanly from your example.

#!/bin/bash

# Prepare a clean Git repo for EK ERP Platform
set -e

echo "📦 Initializing Git repository..."
git init

echo "📝 Creating .gitignore..."

cat << 'EOF' > .gitignore
# Ignore source code inside all service src folders
ek-core-service/src/**
ek-auth-service/src/**
ek-config-service/src/**
ek-workflow-service/src/**
ek-stakeholders-service/src/**
ek-catalog-service/src/**
ek-inventory-service/src/**
ek-procurement-service/src/**
ek-sales-service/src/**
ek-production-service/src/**
ek-logistics-service/src/**
ek-billing-service/src/**
ek-accounts-service/src/**
ek-reporting-service/src/**
ek-projects-service/src/**
ek-hr-service/src/**
ek-assets-service/src/**

# Allow empty src folders via .gitkeep
!ek-core-service/src/.gitkeep
!ek-auth-service/src/.gitkeep
!ek-config-service/src/.gitkeep
!ek-workflow-service/src/.gitkeep
!ek-stakeholders-service/src/.gitkeep
!ek-catalog-service/src/.gitkeep
!ek-inventory-service/src/.gitkeep
!ek-procurement-service/src/.gitkeep
!ek-sales-service/src/.gitkeep
!ek-production-service/src/.gitkeep
!ek-logistics-service/src/.gitkeep
!ek-billing-service/src/.gitkeep
!ek-accounts-service/src/.gitkeep
!ek-reporting-service/src/.gitkeep
!ek-projects-service/src/.gitkeep
!ek-hr-service/src/.gitkeep
!ek-assets-service/src/.gitkeep

# Docker / runtime data
ek-pg-data/
ek-redis-data/
ek-rabbit-data/
ek-service-registry-data/

# Build artifacts
node_modules/
vendor/
dist/
build/
__pycache__/

# Env files
.env
*.env

# OS / editor files
.DS_Store
.idea/
.vscode/
EOF

echo "📁 Adding .gitkeep to src folders..."

for dir in \
  ek-core-service/src \
  ek-auth-service/src \
  ek-config-service/src \
  ek-workflow-service/src \
  ek-stakeholders-service/src \
  ek-catalog-service/src \
  ek-inventory-service/src \
  ek-procurement-service/src \
  ek-sales-service/src \
  ek-production-service/src \
  ek-logistics-service/src \
  ek-billing-service/src \
  ek-accounts-service/src \
  ek-reporting-service/src \
  ek-projects-service/src \
  ek-hr-service/src \
  ek-assets-service/src
do
  if [ -d "$dir" ]; then
    touch "$dir/.gitkeep"
    echo "   → Added $dir/.gitkeep"
  else
    echo "   ⚠️ Warning: $dir does not exist, skipping"
  fi
done

echo "📥 Staging files..."
git add .

echo "💾 Making initial commit..."
git commit -m "Initial commit: EK ERP platform structure (no service source code)"

echo "🌐 Adding remote origin..."

REMOTE_URL="https://github.com/khakin084/ek-erp-platform.git"

if [ "$REMOTE_URL" = "YOUR_REMOTE_URL_HERE" ]; then
  echo "⚠️ No remote URL set. Edit prepare_repo.sh and replace YOUR_REMOTE_URL_HERE."
else
  git remote add origin "$REMOTE_URL"
  echo "✅ Remote origin added: $REMOTE_URL"
fi

echo "🎉 Repository prepared successfully!"