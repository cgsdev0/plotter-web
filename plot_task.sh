#!/usr/bin/env bash

trap 'rm data/pid' EXIT

source config.sh

# ----
if [[ "${DEV:-true}" == true ]]; then
while IFS= read -r line; do
  echo "$line"
  sleep 0.1
done
exit 0
fi
# ----

DEV=/dev/ttyUSB0

stty -F $DEV 9600 raw -echo
exec 3<>$DEV

last=$(<data/status)

buf_remaining() {
  local bytes
  printf '\x1B.B' >&3
  IFS= read -t 1 -n6 bytes <&3
  if [[ $? -ne 0 ]]; then
    echo "Offline" > data/status
    if [[ "$last" != "Offline" ]]; then
      event status Offline | publish progress &
      last=Offline
    fi
    event stop | publish progress &
    exit 5
  else
    echo "Online" > data/status
    if [[ "$last" != "Online" ]]; then
      event status Online | publish progress &
      last=Online
    fi
  fi
  available="${bytes:-0}"
}

buf_remaining

while IFS= read -r line; do
  needed=${#line}
  while [[ $needed -gt $available ]]; do
    sleep 0.1
    buf_remaining
  done
  echo -n "$line" >&3
  ((available-=$needed))
  echo "$line (buf: $available bytes avail.)"
done
