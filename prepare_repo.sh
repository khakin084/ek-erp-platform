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
ek-core/src/**
ek-auth/src/**
ek-config/src/**
ek-workflow/src/**
ek-stakeholders/src/**
ek-catalog/src/**
ek-inventory/src/**
ek-procurement/src/**
ek-sales/src/**
ek-production/src/**
ek-logistics/src/**
ek-billing/src/**
ek-accounts/src/**
ek-reporting/src/**
ek-projects/src/**
ek-hr/src/**
ek-assets/src/**

# Allow empty src folders via .gitkeep
!ek-core/src/.gitkeep
!ek-auth/src/.gitkeep
!ek-config/src/.gitkeep
!ek-workflow/src/.gitkeep
!ek-stakeholders/src/.gitkeep
!ek-catalog/src/.gitkeep
!ek-inventory/src/.gitkeep
!ek-procurement/src/.gitkeep
!ek-sales/src/.gitkeep
!ek-production/src/.gitkeep
!ek-logistics/src/.gitkeep
!ek-billing/src/.gitkeep
!ek-accounts/src/.gitkeep
!ek-reporting/src/.gitkeep
!ek-projects/src/.gitkeep
!ek-hr/src/.gitkeep
!ek-assets/src/.gitkeep

# Docker / runtime data
ek-pg-data/
ek-redis-data/
ek-rabbit-data/
ek-registry-data/

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
  ek-core/src \
  ek-auth/src \
  ek-config/src \
  ek-workflow/src \
  ek-stakeholders/src \
  ek-catalog/src \
  ek-inventory/src \
  ek-procurement/src \
  ek-sales/src \
  ek-production/src \
  ek-logistics/src \
  ek-billing/src \
  ek-accounts/src \
  ek-reporting/src \
  ek-projects/src \
  ek-hr/src \
  ek-assets/src
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