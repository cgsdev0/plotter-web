
source config.sh

TITLE=

LOGGED_OUT=true
if [[ -n "${SESSION[id]}" ]]; then
  LOGGED_OUT=false
fi
if $LOGGED_OUT; then
  htmx_page << EOF
  $TITLE
  <a href='${RECURSE_BASE_URL}/oauth/authorize?client_id=${APP_ID}&redirect_uri=${REDIRECT_URI}&response_type=code'>Login</a>
EOF
  return
fi

if [[ -z "$INTERNAL_REQUEST" ]]; then
  TITLE="<h1>${PROJECT_NAME}</h1>"
fi

if [[ -f "data/pid" ]]; then
htmx_page << EOF
  $TITLE
  $(component /progress)
  <textarea name="code" rows=30 cols=60 readonly>$(cat data/current)</textarea>
  <br>
  <button disabled type="submit">Print!</button>
EOF
else
htmx_page << EOF
  $TITLE
  <form hx-ext="json-enc" hx-post="/plot" hx-swap="outerHTML" hx-encoding='multipart/form-data'>
  <textarea name="code" rows=30 cols=60 placeholder="HPGL code..."></textarea>
  <br>
  <button type="submit">Print!</button>
  </form>
EOF
fi
