#!/system/bin/sh
ui_print '- Wallet Card Audit : nettoyage complet'
BASE=/data/adb/wallet-card-audit
if [ -f "$BASE/watcher.pid" ]; then kill "$(cat "$BASE/watcher.pid" 2>/dev/null)" 2>/dev/null; fi
if [ -f "$BASE/capture.pid" ]; then kill "$(cat "$BASE/capture.pid" 2>/dev/null)" 2>/dev/null; fi
pkill -f 'wallet-card-audit/.capture.tmp' 2>/dev/null || true
pkill -f 'wallet-card-audit/watcher.sh' 2>/dev/null || true
rm -rf "$BASE" 2>/dev/null
ui_print '- Watcher, captures, rapports, verrous et fichiers temporaires supprimes'
ui_print '- Nettoyage complet termine'
exit 0
