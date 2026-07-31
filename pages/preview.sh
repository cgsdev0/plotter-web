source venv/bin/activate
carriage=$(jq -c 'del(.code)' <<< "$REQUEST_BODY")
preview=$(jq -r '.code' <<< "$REQUEST_BODY" \
  | tr -d '\n \t' \
  | tr '[:lower:]' '[:upper:]' \
  | sed 's/;/;\n/g' \
  | python3 preview/plot_preview.py "$carriage")

if [[ $? -eq 0 ]]; then
cat << EOF
<div id="alerts" hx-swap-oob="beforeend">
  <div class="window">
  <div class="title-bar">
  <div class="title-bar-text">Preview</div>
  <div class="title-bar-controls">
	<button aria-label="Close" hx-get="/empty" hx-target="closest .window" hx-swap="outerHTML"></button>
    </div>
  </div>
  <div class="window-body">
  <a href="$preview" target=_blank><img alt="the thing you wanted" src="$preview" style="width:100%"/></a>
      <section class="field-row" style="justify-content: flex-end">
	<button hx-get="/empty" hx-target="closest .window" hx-swap="outerHTML">OK</button>
      </section>
    </div>
</div>
</div>
EOF
else
cat << EOF
<div id="alerts" hx-swap-oob="beforeend">
  <div class="window">
  <div class="title-bar">
  <div class="title-bar-text">ERROR</div>
  <div class="title-bar-controls">
	<button aria-label="Close" hx-get="/empty" hx-target="closest .window" hx-swap="outerHTML"></button>
    </div>
  </div>
  <div class="window-body">
  <p>ERROR</p>
      <section class="field-row" style="justify-content: flex-end">
	<button hx-get="/empty" hx-target="closest .window" hx-swap="outerHTML">Oh no...</button>
	<button hx-get="/empty" hx-target="closest .window" hx-swap="outerHTML">whatevs</button>
      </section>
    </div>
</div>
</div>
EOF
fi