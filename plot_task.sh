#!/usr/bin/env bash

# ----
# echo wtf
# trap 'rm data/pid' EXIT
# while read -r line; do
#   echo "$line"
#   sleep 0.5
# done
# exit 0
# ----

DEV=/dev/ttyUSB0

stty -F $DEV 9600 raw -echo
exec 3<>$DEV

buf_remaining() {
  local bytes
  printf '\x1B.B' >&3
  IFS= read -n6 bytes <&3
  available="${bytes:-0}"
}

buf_remaining

while read -r line; do
  needed=${#line}
  while [[ $needed -gt $available ]]; do
    sleep 0.1
    buf_remaining
  done
  echo -n "$line" >&3
  ((available-=$needed))
  echo "$line (buf: $available bytes avail.)"
done
