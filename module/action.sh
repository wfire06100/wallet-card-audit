#!/system/bin/sh
MODDIR=${0%/*}
ui_print ''
ui_print 'Wallet Card Audit'
ui_print '1) Demarrer un audit manuel'
ui_print '2) Arreter la capture et generer le rapport'
ui_print '3) Statut'
ui_print '4) Auto ON/OFF'
ui_print '0) Quitter'
ui_print ''
printf 'Choix : '
read -r CHOICE
case "$CHOICE" in
 1) exec /system/bin/sh "$MODDIR/audit.sh" start ;;
 2) exec /system/bin/sh "$MODDIR/audit.sh" stop ;;
 3) /system/bin/sh "$MODDIR/audit.sh" status; /system/bin/sh "$MODDIR/daemon.sh" status ;;
 4) exec /system/bin/sh "$MODDIR/daemon.sh" toggle ;;
 0|q|Q) exit 0 ;;
 *) ui_print 'Choix invalide.'; exit 1 ;;
esac
