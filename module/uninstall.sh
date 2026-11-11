#!/system/bin/sh
/system/bin/sh "${0%/*}/engine.sh" shutdown || exit 1
rm -rf /data/adb/wallet-card-audit
