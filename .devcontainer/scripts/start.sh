#!/usr/bin/env bash

# This script is executed when the devcontainer starts.

set -e

cd /home/devcontainer/blogg

if [ -f Gemfile ]; then
  echo "Installing Ruby dependencies..."
  bundle install
  rake postinstall
else
  echo "No Gemfile found, skipping Ruby dependency installation."
fi

echo "Devcontainer started successfully."
