
source config.sh

if [[ -f "data/pid" ]]; then
htmx_page << EOF
  <h1>${PROJECT_NAME}</h1>
  $(component /progress)
  <form hx-post="/plot" hx-swap="outerHTML">
  <textarea name="code" rows=30 cols=60 readonly>$(cat data/current)</textarea>
  <br>
  <button disabled type="submit">Print!</button>
  </form>
EOF
else
htmx_page << EOF
  <h1>${PROJECT_NAME}</h1>
  <form hx-post="/plot" hx-swap="outerHTML">
  <textarea name="code" rows=30 cols=60 placeholder="HPGL code..."></textarea>
  <br>
  <button type="submit">Print!</button>
  </form>
EOF
fi
