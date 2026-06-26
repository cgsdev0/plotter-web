
htmx_page << EOF
<div hx-ext="sse" sse-connect="/sse">
<pre sse-swap="progress" hx-swap="innerHTML">
</pre>
<div sse-swap="update" hx-swap="innerHTML">
</div>
EOF
