#!/bin/bash
set -e

if [[ ! -e /app/Gemfile.lock ]]; then
    bundle install
fi

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
