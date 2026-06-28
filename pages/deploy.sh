# very secure
if [[ -z "${SESSION[id]}" ]]; then
  return $(status_code 401)
fi

echo "OH HELL YEA. ok one sec"
sudo -u rc git pull
sleep 1
systemctl restart plotter-web
