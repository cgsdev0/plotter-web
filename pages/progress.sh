
htmx_page << EOF
<div id="progress" hx-ext="sse" sse-connect="/sse">
<button hx-post="/stop" hx-target="#progress" hx-swap="outerHTML">Stop</button>
<pre sse-swap="progress" hx-swap="innerHTML">
</pre>
<div sse-swap="update" hx-swap="innerHTML">
</div>
EOF
