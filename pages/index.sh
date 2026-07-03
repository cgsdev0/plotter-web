login() {
  LOGGED_OUT=true
  if [[ -n "${SESSION[id]}" ]]; then
    LOGGED_OUT=false
  fi
  if $LOGGED_OUT; then
    htmx_page << EOF
  <div id="login" class="window">
  <div class="title-bar">
  <div class="title-bar-text">Login</div>
  </div>
  <div class="window-body">
  <p>Welcome to the HP ColorPro 7440A Serial Web Gateway!</p>
  <p>Please login with your Recurse account to get started.</p>
      <section class="field-row" style="justify-content: flex-end">
  <button onclick='window.location="${RECURSE_BASE_URL}/oauth/authorize?client_id=${APP_ID}&redirect_uri=${REDIRECT_URI}&response_type=code";'>Login</button>
  </section>
  </div>
  </div>
EOF
  fi
}

detect_status() {
  if [[ -f data/pid ]]; then
    return
  fi
  local DEV=/dev/ttyUSB0

  stty -F $DEV 9600 raw -echo
  exec 3<>$DEV

  printf '\x1B.B' >&3
  IFS= read -t 1 -n6 bytes <&3
  if [[ $? -ne 0 ]]; then
    echo "Offline" > data/status
  else
    echo "Online" > data/status
  fi
  exec 3>&-
}

htmx_page << EOF
  <h1>${PROJECT_NAME}<sup>NEW!</sup></h1>
  <main hx-ext="sse" sse-connect="/sse">
  <div class="window" id="wizard">
  <div class="title-bar">
  <div class="title-bar-text">Print Wizard</div>
  <div class="title-bar-controls">
  <button aria-label="Help" onclick="window.open('https://github.com/recursecenter/wiki/wiki/Plotter-(HP7440A)', '_blank');"></button>
	<button aria-label="Close" hx-get="/empty" hx-target="closest .window" hx-swap="outerHTML"></button>
    </div>
  </div>
  <div class="window-body" id="app" hx-get="/app" hx-trigger="sse:finish,sse:stop">
  $(component /app)
  </div>
  </div>
  $(login)
  $(component /progress)
<div id="alerts">
</div>
  </main>
EOF
