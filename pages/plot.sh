
if [[ "$REQUEST_METHOD" != "POST" ]]; then
  return $(status_code 405)
fi

event_stream() {
  local length=$(wc -l < data/current)
  local line
  local idx=0
  while IFS= read -r line; do
    event "update" "<p>$line</p>" | publish progress
    event "progress" "<p>$idx / $length</p>" | publish progress
    ((idx++))
  done
}

# TODO: validate the code first

if [[ -f data/pid ]]; then
  echo "don't be rude"
  return $(status_code 420)
fi

echo "${FORM_DATA[code]}" \
  | tr -d '\n \t' \
  | sed 's/;/;\n/g' > data/current

component /progress

echo "<textarea readonly rows=30 cols=60>"
cat data/current
echo "</textarea>"

./plot_task.sh < data/current \
  | event_stream 1>&- 2>&- &

echo "$!" > data/pid
