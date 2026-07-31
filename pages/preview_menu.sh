slots=$(jq -r '.code' <<< "$REQUEST_BODY" \
  | tr -d '\n \t' \
  | tr '[:lower:]' '[:upper:]' \
  | sed 's/;/;\n/g' \
  | grep '^SP[1-8]' \
  | tr -dc '[1-8]\n' \
  | sort -u)

to_option() {
    local name r g b t
    while read name r g b t; do
        echo "<option style='color:rgb($r,$g,$b)' value='$name'>
            <div style='background-color:rgb($r,$g,$b);width:20px;height:20px;'>
            </div>
            $name
        </option>"
    done
}

list_options() {
    jq -r 'to_entries | .[] | [.key, .value[]] | @tsv' pens.json \
    | to_option
}

list_pens() {
    local slot
    for slot in $slots; do
        echo "<div><label for='sp$slot'>Pen $slot:</label>"
        echo "<select name='sp$slot'>"
        list_options
        echo "</select></div>"
    done
}

cat << EOF
<div id="alerts" hx-swap-oob="beforeend">
  <div class="window">
  <div class="title-bar">
  <div class="title-bar-text">Pen Selection</div>
  <div class="title-bar-controls">
	<button aria-label="Close" hx-get="/empty" hx-target="closest .window" hx-swap="outerHTML"></button>
    </div>
  </div>
  <div class="window-body">
  <p>Select Colors</p>
  <form>
    $(list_pens)
      <section class="field-row" style="justify-content: flex-end">
	<button hx-get="/empty" hx-target="closest .window" hx-swap="outerHTML">Cancel</button>
	<button hx-ext="json-enc" hx-post="/preview" hx-target="closest .window" hx-swap="outerHTML" hx-include="[name='code']">OK</button>
      </section>
  </form>
    </div>
</div>
</div>
EOF