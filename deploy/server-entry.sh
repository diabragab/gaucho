#!/bin/sh
# Seed the data volume on first run, never overwrite saved accounts/heroes.
set -e
mkdir -p /data
for f in /data-seed/*; do
  name=$(basename "$f")
  [ -e "/data/$name" ] || cp -r "$f" "/data/$name"
done
exec /app/gaucho-server
