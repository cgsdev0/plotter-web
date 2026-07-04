
if [[ -z "${SESSION[id]}" ]]; then
  return $(status_code 401)
fi

rm data/pid

echo Great Success
