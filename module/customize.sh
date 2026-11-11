#!/system/bin/sh
SKIPUNZIP=0
command -v logcat >/dev/null 2>&1 || abort 'logcat absent'
command -v nohup >/dev/null 2>&1 || abort 'nohup absent'
mkdir -p /data/adb/wallet-card-audit
chmod 700 /data/adb/wallet-card-audit
set_perm_recursive "$MODPATH" 0 0 0755 0644
for f in action.sh engine.sh watcher.sh uninstall.sh hotinstall.sh; do set_perm "$MODPATH/$f" 0 0 0755; done
if [ "$KSU_HAS_HOT_INSTALL" = true ]; then
 export MODULE_HOT_INSTALL_REQUEST=true
 export MODULE_HOT_RUN_SCRIPT=hotinstall.sh
 ui_print 'Installation a chaud demandee. Fermez puis rouvrez la WebUI.'
else
 ui_print 'Hot install non declare par ce gestionnaire : activation sans reboot non garantie.'
fi
ui_print 'Version 0.5.1 : aucune modification Wallet/GMS/SELinux.'
