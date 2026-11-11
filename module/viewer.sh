#!/system/bin/sh
umask 077
B=/data/adb/wallet-card-audit
D=${0%/*}
case "${1:-page}" in
 clear)
 [ ! -d "$B/lock" ] || { echo 'Arretez la capture avant suppression.' >&2; exit 1; }
 state=$(/system/bin/sh "$D/engine.sh" status)
 echo "$state" | grep -q '"auto":false' || { echo 'Desactivez le mode automatique avant suppression.' >&2; exit 1; }
 mkdir "$B/lock" 2>/dev/null || exit 1
 trap 'rmdir "$B/lock" 2>/dev/null' EXIT
 for f in "$B"/session-*; do
 [ -d "$f" ] && [ ! -L "$f" ] && rm -rf "$f"
 done
 rm -f "$B/latest" "$B/report.json" "$B/report.json.tmp" "$B/engine.log" "$B/install.log"
 echo 'Sessions, rapport et journaux internes supprimes.';;
 page)
 category=${2:-all}; page=${3:-1}
 case "$page" in ''|*[!0-9]*) exit 2;; esac
 [ "$page" -ge 1 ] && [ "$page" -le 10000 ] || exit 2
 case "$category" in
 all) pattern='.';;
 provisioning) pattern='tapandpay|tap.and.pay|tokeniz|provision';;
 keystore) pattern='keystore|keymint|keymaster|strongbox';;
 attestation) pattern='attest';;
 network) pattern='SSLHandshakeException|UnknownHostException|SocketTimeoutException|ConnectException';;
 crash) pattern='FATAL EXCEPTION';;
 *) exit 2;;
 esac
 [ -f "$B/latest/events.txt" ] || { echo 'Aucun evenement : arreter la capture puis actualiser.'; exit 0; }
 start=$(( (page-1)*100+1 )); end=$((page*100))
 echo "--- Filtre: $category | Page: $page | 100 lignes maximum ---"
 grep -Ei "$pattern" "$B/latest/events.txt" | sed -n "${start},${end}p"
 ;;
 *) exit 2;;
esac
