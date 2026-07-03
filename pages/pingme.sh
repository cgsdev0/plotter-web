WHO=${QUERY_PARAMS[ip]}
WHO=${WHO//[^.0-9]/}
WHO=${WHO:-10.100.4.53}


htmx_page << EOF
<pre>
$(ping -c 5 "$WHO")
</pre>
EOF
