#!/system/bin/sh
MODDIR=${0%/*}
CMD=${1:-menu}
case "$CMD" in
  start) exec /system/bin/sh "$MODDIR/audit.sh" start ;;
  stop) exec /system/bin/sh "$MODDIR/audit.sh" stop ;;
  status)
    /system/bin/sh "$MODDIR/audit.sh" status
    /system/bin/sh "$MODDIR/daemon.sh" status
    ;;
  auto-on) exec /system/bin/sh "$MODDIR/daemon.sh" start ;;
  auto-off) exec /system/bin/sh "$MODDIR/daemon.sh" stop ;;
  *)
    echo 'Wallet Card Audit'
    echo '1) start - demarrer une capture manuelle'
    echo '2) stop - arreter la capture'
    echo '3) status - etat de l audit et du mode auto'
    echo '4) auto-on - activer la capture automatique Wallet'
    echo '5) auto-off - desactiver la capture automatique'
    ;;
esac
