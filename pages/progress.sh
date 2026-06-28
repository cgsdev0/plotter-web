
htmx_page << EOF
<div id="progress" hx-ext="sse" sse-connect="/sse">
<button hx-post="/stop" hx-target="#progress" hx-swap="outerHTML">Stop</button>
<div sse-swap="progress" hx-swap="innerHTML">
</div>
<pre sse-swap="update" hx-swap="innerHTML">
</pre>
EOF
