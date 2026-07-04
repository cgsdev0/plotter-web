
if [[ "$REQUEST_METHOD" != "POST" ]]; then
  return $(status_code 405)
fi

# very secure
if [[ -z "${SESSION[id]}" ]]; then
  return $(status_code 401)
fi

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

progress_bar() {
cat << EOF | tr -d '\n'
<div class="progress-indicator segmented">
<span class="progress-indicator-bar" style="width: $1%;" />
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
  event "finish" "$(done_box)" | publish progress &
}

# TODO: validate the code first

if [[ -f data/pid ]]; then
  echo "don't be rude"
  return $(status_code 420)
fi

code=$(jq -r '.code' <<< "$REQUEST_BODY")

if [[ -z "$code" ]]  || [[ $code == "null" ]]; then
  return $(status_code 400)
fi


max_len=$(awk '{ if (length > max) max = length } END { print max }' <<< "$code")
if ((max_len > 60)); then
  echo "<div id='status' hx-swap-oob='innerHTML'>Invalid hpgl</div>"
  return
fi

jq -r '.code' <<< "$REQUEST_BODY" \
  | tr -d '\n \t' \
  | sed 's/;/;\n/g' > data/current


./plot_task.sh < data/current \
  | event_stream 1>&- 2>&- &

echo "$!" > data/pid

echo '<content id="app" hx-swap-oob="innerHTML">'
component /app
echo '</content>'
component /progress
