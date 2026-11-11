#!/system/bin/sh
SKIPUNZIP=0
ui_print '- Wallet Card Audit v0.3.0'
if ! command -v logcat >/dev/null 2>&1; then
  ui_print '! logcat introuvable : audit indisponible'
  abort
fi
DATA=/data/adb/wallet-card-audit
mkdir -p "$DATA" || abort
chmod 700 "$DATA" 2>/dev/null || true
set_perm_recursive "$MODPATH" 0 0 0755 0644
for f in action.sh audit.sh watcher.sh daemon.sh uninstall.sh; do
  set_perm "$MODPATH/$f" 0 0 0755
done
{
  echo "installed=$(date -u +%FT%TZ)"
  echo "android=$(getprop ro.build.version.release)"
  echo "sdk=$(getprop ro.build.version.sdk)"
  echo "security_patch=$(getprop ro.build.version.security_patch)"
  echo "auto_enabled=false"
} > "$DATA/install.log" 2>&1
ui_print '- Installation terminee'
ui_print '- Action : start, stop, status, auto-on, auto-off'
