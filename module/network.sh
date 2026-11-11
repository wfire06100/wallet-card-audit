#!/system/bin/sh
umask 077
D=${0%/*}; B=/data/adb/wallet-card-audit
. "$D/network-patterns.sh" || exit 1
case "${1:-status}" in
 status) if [ -f "$B/network-enabled" ]; then echo ON; else echo OFF; fi;;
 toggle)
 state=$(/system/bin/sh "$D/engine.sh" status) || exit 1
 case "$state" in *'"capture":"stopped"'*'"auto":false'*) ;; *) echo 'Stop capture and turn Automatic OFF first.' >&2; exit 1;; esac
 mkdir "$B/lock" 2>/dev/null || { echo 'Another operation is running.' >&2; exit 1; }
 trap 'rmdir "$B/lock" 2>/dev/null || true' EXIT
 if [ -f "$B/network-enabled" ]; then rm "$B/network-enabled" || exit 1; echo OFF
 else : > "$B/network-enabled" || exit 1; echo ON; fi;;
 page)
 page=${2:-1}
 case "$page" in ''|*[!0-9]*) exit 2;; esac
 [ "$page" -ge 1 ] && [ "$page" -le 10000 ] || exit 2
 [ ! -d "$B/lock" ] || { echo 'Stop capture before viewing network diagnostics.' >&2; exit 1; }
 echo 'Passive network clues only. Origin and server attribution: unverified.'
 echo 'HTTPS payload: not captured by this feature. Bodies are unavailable unless already logged.'
 echo 'Matches do not prove a public-key rejection or identify a bank, issuer or server.'
 echo "--- Network clues | Page $page | Up to 100 lines ---"
 [ -f "$B/latest/events.txt" ] || { echo 'No retained events available.'; exit 0; }
 first=$(((page-1)*100+1)); last=$((page*100))
 awk -v pat="$NETWORK_PATTERN" -v first="$first" -v last="$last" 'tolower($0) ~ pat {n++; if(n>=first && n<=last) print} END {print "--- Total matching retained lines: " n+0 " ---"}' "$B/latest/events.txt"
 ;;
 *) exit 2;;
esac
