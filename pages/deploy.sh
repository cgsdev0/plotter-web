# very secure
if [[ -z "${SESSION[id]}" ]]; then
  return $(status_code 401)
fi

delayed() {
  sudo -u rc git pull
  sleep 1
  systemctl restart plotter-web
}

0&>- delayed 1&>- 2&>- &

echo "OH HELL YEA. ok one sec"
