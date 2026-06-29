
LOGGED_OUT=true
if [[ -n "${SESSION[id]}" ]]; then
  LOGGED_OUT=false
fi
if $LOGGED_OUT; then
  htmx_page << EOF
  <h1>${PROJECT_NAME}</h1>
  <a href='${RECURSE_BASE_URL}/oauth/authorize?client_id=${APP_ID}&redirect_uri=${REDIRECT_URI}&response_type=code'>Login</a>
EOF
  return
fi


htmx_page << EOF
  <h1>${PROJECT_NAME}</h1>
  <main hx-ext="sse" sse-connect="/sse">
  <div id="status" sse-swap="finish">
  </div>
  <content id="app" hx-get="/app" hx-trigger="sse:finish">
  $(component /app)
  </content>
  </main>
EOF
