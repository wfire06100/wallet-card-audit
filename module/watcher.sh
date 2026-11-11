#!/system/bin/sh
WALLET_PKG=com.google.android.apps.walletnfcrel
BASE=/data/adb/wallet-card-audit
STATE_FILE="$BASE/.wallet_foreground"
PREV=false
while true; do
  CURRENT=$(dumpsys activity activities 2>/dev/null | grep -m1 'topResumedActivity=' || true)
  if echo "$CURRENT" | grep -q "$WALLET_PKG"; then NOW=true; else NOW=false; fi
  if [ "$NOW" = true ] && [ "$PREV" != true ]; then
    /system/bin/sh "${0%/*}/audit.sh" start >/dev/null 2>&1 &
    echo true > "$STATE_FILE"
  elif [ "$NOW" = false ] && [ "$PREV" = true ]; then
    /system/bin/sh "${0%/*}/audit.sh" stop >/dev/null 2>&1
    echo false > "$STATE_FILE"
  fi
  PREV=$NOW
  sleep 2
done
