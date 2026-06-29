# headers


if [[ "$REQUEST_METHOD" != "POST" ]]; then
  end_headers
  end_headers
  return $(status_code 405)
fi

# very secure
if [[ -z "${SESSION[id]}" ]]; then
  end_headers
  end_headers
  return $(status_code 401)
fi

if [[ ! -f data/pid ]]; then
  end_headers
  end_headers
  return $(status_code 400)
fi

kill $(cat data/pid) &> /dev/null

header HX-Refresh true
end_headers
end_headers

