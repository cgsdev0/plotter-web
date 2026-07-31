#!/usr/bin/env bash

trap 'rm data/pid' EXIT

source config.sh

progress_bar() {
cat << EOF | tr -d '\n'
<div class="progress-indicator segmented">
<span class="progress-indicator-bar" style="width: $1%;" />
</div>
EOF
}

done_box() {
cat << EOF | tr -d '\n'
<div id="alerts" hx-swap-oob="beforeend">
  <div class="window">
  <div class="title-bar">
  <div class="title-bar-text">Done!</div>
  <div class="title-bar-controls">
	<button aria-label="Close" hx-get="/empty" hx-target="closest .window" hx-swap="outerHTML"></button>
    </div>
  </div>
  <div class="window-body">
  <p>The print completed successfully.</p>
      <section class="field-row" style="justify-content: flex-end">
	<button hx-get="/empty" hx-target="closest .window" hx-swap="outerHTML">OK</button>
      </section>
    </div>
</div>
</div>
EOF
}

event_stream() {
  event "start" | publish progress &
  local start=$(date +%s%N)
  local length=$(wc -l < data/current)
  local line
  local idx=1
  local last=$(date +%s%N)
  while IFS= read -r line; do
    local now=$(date +%s%N)
    local delta=$((now - start))
    local delta2=$((now - last))
    local eta=$((delta*(length-idx)/idx/1000000000))
    local mins=$((eta/60))
    local seconds=$((eta%60))
    if ((delta2 > 200000000)); then
      last=$now
      printf -v remaining "%02d:%02d" $mins $seconds
      percent=$((idx * 100 / length));
      { event "update" "$remaining remaining" "$line";
	event "progress" "$(progress_bar $percent )"; } | publish progress &
    fi
    ((idx++))
  done
  sleep 2
  event "finish" "$(done_box)" | publish progress &
}

# ---- DEV MODE SIM ----
if [[ "${DEV:-true}" == true ]]; then
while IFS= read -r line; do
  echo "$line"
  sleep 0.1
done | event_stream
exit 0
fi
# ---- END DEV MODE ----


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
done | event_stream
