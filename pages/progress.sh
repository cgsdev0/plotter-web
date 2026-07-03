
if [[ ! -f data/pid ]]; then
htmx_page << EOF
<div id="progress" class="hidden" hx-swap-oob=true hx-get="/progress" hx-trigger="sse:start">
</div>
EOF
    return
fi

htmx_page << EOF
  <div class="window" id="progress" hx-swap-oob=true hx-get="/progress" hx-trigger="sse:finish,sse:stop">
  <div class="title-bar">
  <div class="title-bar-text">Print Progress</div>
  <div class="title-bar-controls">
    <button aria-label="Close"></button>
    </div>
  </div>
  <div class="window-body">
  <div class="cimg">
  <img src="/static/move.gif" />
  </div>
    <div sse-swap="progress">
    </div>
    <div sse-swap="finish">
    </div>
    <pre sse-swap="update">
    </pre>
    </div>
</div>
EOF
