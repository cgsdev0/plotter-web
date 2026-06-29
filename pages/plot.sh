
if [[ "$REQUEST_METHOD" != "POST" ]]; then
  return $(status_code 405)
fi

# very secure
if [[ -z "${SESSION[id]}" ]]; then
  return $(status_code 401)
fi

event_stream() {
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
      { event "update" "$remaining remaining" "$line";
  event "progress" "<progress id='file' max='$length' value='$idx'>$idx / $length</progress>"; } | publish progress
    fi
    ((idx++))
  done
  event "finish" "Done!"| publish progress
}

# TODO: validate the code first

if [[ -f data/pid ]]; then
  echo "don't be rude"
  return $(status_code 420)
fi

jq -r '.code' <<< "$REQUEST_BODY" \
  | tr -d '\n \t' \
  | sed 's/;/;\n/g' > data/current


max_len=$(awk '{ if (length > max) max = length } END { print max }' < data/current)
if ((max_len > 60)); then
  echo "<div id='status' hx-swap-oob='innerHTML'>Invalid hpgl</div>"
  return
fi


./plot_task.sh < data/current \
  | event_stream 1>&- 2>&- &

echo "$!" > data/pid

echo '<content id="app" hx-swap-oob="innerHTML">'
component /app
echo '</content>'
