# Victoriametrics VMUI access
if [ "$CONFIG_VICTORIAMETRICS" == "on" ]; then
  for CFG in etc/victoriametrics/conf.d/*.conf; do
    . $CFG
  done

  export VMPROTOCOL=http
  [ $CONFIG_VICTORIAMETRICS_MODE = ssl ] && VMPROTOCOL=https

  VMUI_AUTH=
  if [ "$vm_httpAuth_username" ] && [ "$vm_httpAuth_password" ] ; then
      VMUI_AUTH=$(printf "%s:%s" "$vm_httpAuth_username" "$vm_httpAuth_password" | base64)
  fi
  export VMUI_AUTH
fi
