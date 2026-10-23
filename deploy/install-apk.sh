#!/bin/bash
# Installs (or updates) the gaucho apk on the cloud android.
# The apk must point at 127.0.0.1 (the default Gaucho.apk does).
# Usage:  ./deploy/install-apk.sh path/to/Gaucho.apk
set -euo pipefail
cd "$(dirname "$0")"
APK="$(realpath "${1:?usage: install-apk.sh <apk>}")"

docker compose cp "$APK" scrcpy:/tmp/game.apk
docker compose exec scrcpy bash -c '
  adb connect redroid:5555 >/dev/null
  until [ "$(adb -s redroid:5555 shell getprop sys.boot_completed | tr -d "\r")" = "1" ]; do
    echo "waiting for android to boot..."; sleep 5
  done
  adb -s redroid:5555 install -r /tmp/game.apk
  for p in 8020 5816 9528; do adb -s redroid:5555 reverse tcp:$p tcp:$p; done
  rm /tmp/game.apk
'
echo "installed. open the server address in a browser, pick the device, then H264 Converter."
