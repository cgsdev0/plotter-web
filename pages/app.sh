
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
    echo '<textarea id="code" name="code" rows=30 cols=60 placeholder="HPGL code...">'
	[[ -f data/pid ]]&& cat data/current
	echo "</textarea>"
}

function restore_button {
	local disabled
	[[ -f data/pid ]]&& disabled=disabled
	echo "<button hx-get='/restore' hx-swap='textContent' hx-target='#code' $disabled>Restore</button>"
}

htmx_page <<-EOF
      <div sse-swap="progress">
      </div>
	  <div sse-swap="finish">
	  </div>
      <pre sse-swap="update">
      </pre>
      <form hx-ext="json-enc" hx-post="/plot" hx-encoding='multipart/form-data' hx-swap="none">
	  $(print_button)
	  $(stop_button)
	  $(restore_button)
      <br>
	  $(text_area)
      </form>
EOF
