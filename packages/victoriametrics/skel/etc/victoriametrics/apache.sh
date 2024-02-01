export VMPROTOCOL=http
export VMUI_AUTH=
# Victoriametrics VMUI access
if [ "$CONFIG_VICTORIAMETRICS" == "on" ]; then
  for CFG in etc/victoriametrics/conf.d/*.conf; do
    . $CFG
  done

  [ $CONFIG_VICTORIAMETRICS_MODE = ssl ] && VMPROTOCOL=https

  if [ "$vm_httpAuth_username" ] && [ "$vm_httpAuth_password" ] ; then
      VMUI_AUTH=$(printf "%s:%s" "$vm_httpAuth_username" "$vm_httpAuth_password" | base64)
  fi
fi
