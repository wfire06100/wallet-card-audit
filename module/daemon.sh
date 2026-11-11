#!/system/bin/sh
MODDIR=${0%/*}
BASE=/data/adb/wallet-card-audit
PIDFILE="$BASE/watcher.pid"
CMD=${1:-status}
is_running() { [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE" 2>/dev/null)" 2>/dev/null; }
case "$CMD" in
  start)
    if is_running; then echo 'Mode automatique deja actif.'; exit 0; fi
    mkdir -p "$BASE"
    nohup /system/bin/sh "$MODDIR/watcher.sh" >/dev/null 2>&1 &
    echo $! > "$PIDFILE"
    echo 'Mode automatique active : capture uniquement lorsque Wallet est au premier plan.'
    ;;
  stop)
    if [ -f "$PIDFILE" ]; then kill "$(cat "$PIDFILE" 2>/dev/null)" 2>/dev/null; rm -f "$PIDFILE"; fi
    /system/bin/sh "$MODDIR/audit.sh" stop >/dev/null 2>&1
    echo 'Mode automatique desactive.'
    ;;
  toggle)
    if is_running; then exec /system/bin/sh "$0" stop; else exec /system/bin/sh "$0" start; fi
    ;;
  status)
    if is_running; then echo 'Mode automatique actif.'; else echo 'Mode automatique inactif.'; fi
    ;;
  *) echo 'Usage: daemon.sh start|stop|toggle|status' ;;
esac
