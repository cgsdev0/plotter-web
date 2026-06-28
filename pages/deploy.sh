# very secure
AUTH=${HTTP_HEADERS[Authorization]}
if [[ "$AUTH" != "$MAGIC_DEPLOY_TOKEN" ]]; then
  return $(status_code 401)
fi

echo "OH HELL YEA. ok one sec"
sudo -u rc git pull
sleep 1
systemctl restart plotter-web
