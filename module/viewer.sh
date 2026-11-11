#!/system/bin/sh
umask 077
B=/data/adb/wallet-card-audit
D=${0%/*}
case "${1:-page}" in
 clear)
 [ ! -d "$B/lock" ] || { echo 'Stop capture before deleting logs.' >&2; exit 1; }
 state=$(/system/bin/sh "$D/engine.sh" status) || exit 1
 case "$state" in *'"auto":false'*) ;; *) echo 'Turn automatic mode OFF first.' >&2; exit 1;; esac
 mkdir "$B/lock" 2>/dev/null || { echo 'Another operation is running.' >&2; exit 1; }
 trap 'rmdir "$B/lock" 2>/dev/null || true' EXIT
 failed=0
 for f in "$B"/session-*; do
 [ -e "$f" ] || [ -L "$f" ] || continue
 rm -rf "$f" || failed=1
 done
 rm -f "$B/latest" "$B/report.json" "$B/report.json.tmp" "$B/engine.log" "$B/install.log" || failed=1
 for f in "$B"/session-* "$B/latest" "$B/report.json" "$B/report.json.tmp" "$B/engine.log" "$B/install.log"; do
 if [ -e "$f" ] || [ -L "$f" ]; then echo "Could not remove: $f" >&2; failed=1; fi
 done
 [ "$failed" -eq 0 ] || exit 1
 echo 'Logs, sessions and report deleted.'
 exit 0;;
 page)
 category=${2:-all}; page=${3:-1}
 case "$page" in ''|*[!0-9]*) exit 2;; esac
 [ "$page" -ge 1 ] && [ "$page" -le 10000 ] || exit 2
 case "$category" in
 all) pattern='.';;
 provisioning) pattern='tapandpay|tap.and.pay|tokeniz|provision';;
 keystore) pattern='keystore|keymint|keymaster|strongbox|teesimulator|systemlogger|softwareoperation|operationinterceptor|createoperation|generatekey|authorizecreate|txid|creating software operation|found new ikeystoreoperation|registering interceptor|restoring persisted key|failed to restore key|failed to restore symmetric metadata';;
 attestation) pattern='attest';;
 network) pattern='SSLHandshakeException|UnknownHostException|SocketTimeoutException|ConnectException';;
 crash) pattern='FATAL EXCEPTION';;
 *) exit 2;; esac
 [ -f "$B/latest/events.txt" ] || { echo 'No events. Stop capture to generate the filtered log.'; exit 0; }
 start=$(( (page-1)*100+1 )); end=$((page*100))
 echo "--- Filter: $category | Page: $page | Up to 100 lines ---"
 awk -v pat="$pattern" -v first="$start" -v last="$end" 'tolower($0) ~ tolower(pat) {n++; if(n>=first) print; if(n>=last) exit}' "$B/latest/events.txt"
 ;;
 *) exit 2;; esac
