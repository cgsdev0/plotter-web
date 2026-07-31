

function print_button {
	local disabled
	[[ -f data/pid ]]&& disabled=disabled
	echo "<button type='submit' $disabled>Print!</button>"
}

function stop_button {
	local disabled
	[[ ! -f data/pid ]]&& disabled=disabled
	echo "<button hx-post='/stop' $disabled>Stop</button>"
}

function text_area {
    echo '<div class="textbox"><textarea rows=10 id="code" name="code" placeholder="HPGL code..." hx-preserve="true">'
	[[ -f data/pid ]] && cat data/current
    echo "</textarea></div>"
}

function restore_button {
	local disabled
	[[ -f data/pid ]]&& disabled=disabled
	echo "<button hx-get='/restore' hx-swap='textContent' hx-target='#code' $disabled>Restore</button>"
}

function preview_button {
	echo "<button hx-post='/preview_menu' hx-include="[name='code']">Preview</button>"
}

htmx_page <<-EOF
      <form hx-ext="json-enc" hx-post="/plot" hx-encoding='multipart/form-data' hx-swap="none">
    <div style="margin: 1rem 0;">
	  $(text_area)
    </div>
      <section class="field-row" style="justify-content: flex-end">
    <div class="status-field-border" style="padding: 5px; flex: 1;">
    Plotter status: <span hx-swap='textContent' sse-swap='status'>$(cat data/status)</span>
</div>
	  $(print_button)
	  $(stop_button)
	  $(restore_button)
	  $(preview_button)
	  </section>
      </form>
EOF
