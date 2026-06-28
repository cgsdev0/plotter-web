# very secure
if [[ -z "${SESSION[id]}" ]]; then
  return $(status_code 401)
fi

git pull

delayed() {
  sleep 3
  sudo systemctl restart plotter-web
}

0&>- delayed 1&>- 2&>- &

echo "OH HELL YEA. ok one sec"
