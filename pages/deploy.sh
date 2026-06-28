# very secure
if [[ -z "${SESSION[id]}" ]]; then
  return $(status_code 401)
fi

sudo -u rc git pull
echo

delayed() {
  sleep 1
  sudo systemctl restart plotter-web
}

0&>- delayed 1&>- 2&>- &

echo "OH HELL YEA. ok one sec"
