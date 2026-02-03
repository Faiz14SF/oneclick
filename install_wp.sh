#!/bin/bash

# Exit if any command fails
set -e

# Prompt for WordPress version
read -p "Enter WordPress version to install (e.g., 6.8.1): " WP_VERSION

# Validate version format
if [[ ! $WP_VERSION =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
  echo "❌ Invalid version format. Please enter like '6.8.1'"
  exit 1
fi

# Prompt for cPanel username
read -p "Enter cPanel username (for file ownership): " CPANEL_USER

# Check if user exists
if ! id "$CPANEL_USER" &>/dev/null; then
  echo "❌ User '$CPANEL_USER' does not exist."
  exit 1
fi

# Variables
WP_TAR="wordpress-$WP_VERSION.tar.gz"
WP_URL="https://wordpress.org/$WP_TAR"

echo "📥 Downloading WordPress $WP_VERSION..."
wget -q "$WP_URL" || { echo "❌ Failed to download $WP_TAR"; exit 1; }

echo "📦 Extracting..."
tar -xzf "$WP_TAR"

echo "🔒 Setting ownership to $CPANEL_USER:$CPANEL_USER..."
chown -R "$CPANEL_USER:$CPANEL_USER" wordpress

echo "📂 Syncing files to current directory..."
rsync -avzp wordpress/ ./

echo "🧹 Cleaning up..."
rm -rf wordpress "$WP_TAR"

echo "✅ WordPress $WP_VERSION installed successfully for user $CPANEL_USER."
