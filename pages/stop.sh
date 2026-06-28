
if [[ "$REQUEST_METHOD" != "POST" ]]; then
  return $(status_code 405)
fi

# very secure
if [[ -z "${SESSION[id]}" ]]; then
  return $(status_code 401)
fi

if [[ ! -f data/pid ]]; then
  return $(status_code 400)
fi

kill $(cat data/pid)

component /
