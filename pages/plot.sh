
if [[ "$REQUEST_METHOD" != "POST" ]]; then
  return $(status_code 405)
fi

# very secure
if [[ -z "${SESSION[id]}" ]]; then
  return $(status_code 401)
fi



# TODO: validate the code first

if [[ -f data/pid ]]; then
  echo "don't be rude"
  return $(status_code 420)
fi

code=$(jq -r '.code' <<< "$REQUEST_BODY" \
  | tr -d '\n \t' \
  | tr '[:lower:]' '[:upper:]' \
  | sed 's/;/;\n/g')

if [[ -z "$code" ]]  || [[ $code == "null" ]]; then
  return $(status_code 400)
fi


max_len=$(awk '{ if (length > max) max = length } END { print max }' <<< "$code")
if ((max_len > 60)); then
  echo "<div id='status' hx-swap-oob='innerHTML'>Invalid hpgl</div>"
  return
fi


jq -r '.code' <<< "$REQUEST_BODY" \
  | tr -d '\n \t' | tr '[:lower:]' '[:upper:]' \
  | sed 's/;/;\n/g' > data/current


./plot_task.sh < data/current 1>&- 2>&- &

echo "$$" > data/pid

debug "$$"

echo '<content id="app" hx-swap-oob="innerHTML">'
component /app
echo '</content>'
component /progress
