#!/bin/bash
# Connects adb to the redroid device and keeps the game ports reversed:
# inside android, 127.0.0.1:8020/5816/9528 -> this container's localhost,
# which is the gaucho server (shared network namespace).
DEVICE="${ANDROID_DEVICE:-redroid:5555}"

keep_linked() {
  while true; do
    adb connect "$DEVICE" >/dev/null 2>&1
    if [ "$(adb -s "$DEVICE" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; then
      for p in 8020 5816 9528; do
        adb -s "$DEVICE" reverse "tcp:$p" "tcp:$p" >/dev/null 2>&1
      done
    fi
    sleep 15
  done
}

adb start-server
keep_linked &
cd /opt/ws-scrcpy/dist
exec npm start
