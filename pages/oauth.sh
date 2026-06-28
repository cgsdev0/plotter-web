# headers

source config.sh

ACCESS_TOKEN=$(curl -Ss -X POST \
  "$RECURSE_BASE_URL/oauth/token?grant_type=authorization_code&code=${QUERY_PARAMS[code]}&redirect_uri=${REDIRECT_URI}&client_id=${APP_ID}&client_secret=${APP_SECRET}" \
 | jq -r '.access_token')

if [[ "$ACCESS_TOKEN" == null ]]; then
  end_headers
  end_headers
  return $(status_code 401)
fi

DATA=$(curl -Ss "$RECURSE_BASE_URL/api/v1/profiles/me" \
  --header "Authorization: Bearer $ACCESS_TOKEN")

ID=$(echo "$DATA" | jq -r '.id')

if [[ "$ID" == null ]]; then
  end_headers
  end_headers
  return $(status_code 401)
fi

header Location /
end_headers
end_headers

SESSION[id]=$ID
save_session

return $(status_code 302)
