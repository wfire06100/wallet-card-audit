#!/system/bin/sh
umask 077
B=/data/adb/wallet-card-audit
encoded=$1
page=${2:-1}
case "$encoded" in ''|*[!A-Za-z0-9+/=]*) echo 'Invalid encoded filter' >&2; exit 2;; esac
[ "${#encoded}" -le 684 ] || exit 2
case "$page" in ''|*[!0-9]*) exit 2;; esac
[ "$page" -ge 1 ] && [ "$page" -le 10000 ] || exit 2
WCA_NEEDLE=$(printf '%s' "$encoded" | base64 -d) || exit 2
[ -n "$WCA_NEEDLE" ] || exit 2
export WCA_NEEDLE
[ -f "$B/latest/events.txt" ] || { echo 'No events. Stop capture first.'; exit 0; }
start=$(( (page-1)*100+1 )); end=$((page*100))
printf '%s\n' "--- Literal search | Page: $page | Up to 100 lines ---"
awk -v first="$start" -v last="$end" 'BEGIN {needle=tolower(ENVIRON["WCA_NEEDLE"])} index(tolower($0),needle) {n++; if(n>=first) print; if(n>=last) exit}' "$B/latest/events.txt"
