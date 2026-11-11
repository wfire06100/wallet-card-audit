#!/system/bin/sh
umask 077
D=${0%/*}; B=/data/adb/wallet-card-audit
mkdir -p "$B"; chmod 700 "$B"
live() {
 [ -f "$B/$1.pid" ] || return 1
 p=$(cat "$B/$1.pid")
 case "$p" in ''|*[!0-9]*) return 1;; esac
 [ -r "/proc/$p/cmdline" ] || return 1
 tr '\000' ' ' < "/proc/$p/cmdline" | grep -Fq "$2"
}
stop() {
 [ -d "$B/lock" ] || return 0
 touch "$B/stop"; i=0
 while [ -d "$B/lock" ] && [ "$i" -lt 25 ]; do sleep 1; i=$((i+1)); done
 [ ! -d "$B/lock" ] || { echo 'Stop not confirmed. Open Diagnostics.' >&2; return 1; }
}
status() {
 s=stopped; a=false
 [ -d "$B/lock" ] && s=starting
 if live worker 'engine.sh worker'; then
 s=capturing
 if [ -f "$B/started" ]; then
 start=$(cat "$B/started")
 case "$start" in ''|*[!0-9]*) ;; *) elapsed=$(($(date +%s)-start)); [ "$elapsed" -ge 30 ] || s="Preparing: $((30-elapsed))s remaining (recording already active)";; esac
 fi
 fi
 [ -f "$B/finalizing" ] && s=finalizing
 live watcher watcher.sh && a=true
 version=$(sed -n 's/^version=//p' "$D/module.prop")
 case "$version" in ''|*[!0-9.]*) version=unknown;; esac
 printf '{"version":"%s","capture":"%s","auto":%s}\n' "$version" "$s" "$a"
}
case "${1:-status}" in
 start)
 mkdir "$B/lock" 2>/dev/null || { echo 'Capture active or stale lock.' >&2; exit 1; }
 rm -f "$B/stop" "$B/finalizing" "$B/started"
 nohup /system/bin/sh "$D/engine.sh" worker </dev/null >>"$B/engine.log" 2>&1 &
 sleep 2
 live worker 'engine.sh worker' || { echo 'Capture failed. Open Diagnostics.' >&2; exit 1; }
 status;;
 stop) stop || exit 1; status;;
 toggle) if [ -d "$B/lock" ]; then stop || exit 1; status; else exec /system/bin/sh "$0" start; fi;;
 auto-toggle)
 if live watcher watcher.sh; then kill "$p" || exit 1; rm -f "$B/watcher.pid"; stop || exit 1
 else
 nohup /system/bin/sh "$D/watcher.sh" </dev/null >>"$B/engine.log" 2>&1 &
 sleep 1; live watcher watcher.sh || exit 1
 fi
 status;;
 shutdown)
 if live watcher watcher.sh; then kill "$p" || exit 1; fi
 rm -f "$B/watcher.pid"; stop;;
 status) status;;
 report) if [ -f "$B/report.json" ]; then cat "$B/report.json"; else echo '{"available":false}'; fi;;
 logs) if [ -f "$B/latest/events.txt" ]; then tail -n 150 "$B/latest/events.txt"; else echo 'No events. Stop capture first.'; fi;;
 diagnostics)
 id; cat "$D/module.prop"; status
 echo '--- engine ---'; tail -n 60 "$B/engine.log" 2>/dev/null
 echo '--- logcat stderr ---'; cat "$B/latest/capture-errors.txt" 2>/dev/null
 echo '--- context ---'; cat "$B/latest/context.txt" 2>/dev/null
 exit 0;;
 worker)
 O="$B/session-$(date +%Y%m%d-%H%M%S)-$$"
 mkdir -p "$O" || { rmdir "$B/lock"; exit 1; }
 echo $$ > "$B/worker.pid"
 rm -f "$B/latest"; ln -s "$O" "$B/latest"
 P=
 cleanup() {
 if [ -n "$P" ]; then kill "$P" 2>/dev/null; wait "$P" 2>/dev/null; fi
 rm -f "$O/raw.tmp" "$B/worker.pid" "$B/finalizing" "$B/stop" "$B/started"
 rmdir "$B/lock" 2>/dev/null
 }
 trap cleanup EXIT
 trap 'touch "$B/stop"' TERM INT HUP
 {
 date -u; id; getprop ro.build.version.release
 echo 'Collection: main/system/crash, all tags and priorities; post-selection by tag OR message.'
 echo 'UI tags excluded from retained events. Shared tags can still include unrelated apps.'
 } > "$O/context.txt" 2>&1
 logcat -b main -b system -b crash -v threadtime -T 1 '*:V' > "$O/raw.tmp" 2> "$O/capture-errors.txt" &
 P=$!; date +%s > "$B/started"; i=0
 while kill -0 "$P" 2>/dev/null && [ ! -f "$B/stop" ] && [ "$i" -lt 600 ]; do
 size=$(wc -c < "$O/raw.tmp"); [ "$size" -lt 20971520 ] || break
 sleep 1; i=$((i+1))
 done
 touch "$B/finalizing"
 kill "$P" 2>/dev/null; wait "$P" 2>/dev/null; P=
 bytes=$(wc -c < "$O/raw.tmp" | tr -d ' ')
 /system/bin/sh "$D/select-events.sh" "$O/raw.tmp" > "$O/events.txt"
 select_code=$?
 lines=$(wc -l < "$O/events.txt" | tr -d ' ')
 err=0; [ -s "$O/capture-errors.txt" ] && err=1
 [ "$select_code" -eq 0 ] || { err=1; echo 'Event selection failed' >> "$O/capture-errors.txt"; }
 printf '{"available":true,"raw_bytes":%s,"filtered_lines":%s,"stderr_present":%s,"seconds":%s,"outcome":"unknown","findings":[' "$bytes" "$lines" "$err" "$i" > "$O/report.json"
 sep=
 for kind in attestation provisioning network keystore crash; do
 case "$kind" in
 attestation) pattern='attest';;
 provisioning) pattern='tapandpay|tap.and.pay|tokeniz|provision|failed to create encrypteddata';;
 network) pattern='SSLHandshakeException|UnknownHostException|SocketTimeoutException|ConnectException';;
 keystore) pattern='keystore|keymint|keymaster|strongbox|teesimulator|systemlogger|softwareoperation|operationinterceptor|createoperation|generatekey|importkey|post-importkey|authorizecreate|keyid|not found|forwarding to hal|generating software key|txid|creating software operation|found new ikeystoreoperation|registering interceptor|restoring persisted key|failed to restore key|failed to restore symmetric metadata|keymint_finish_operation|verification_failed|failed to create encrypteddata';;
 crash) pattern='FATAL EXCEPTION';;
 esac
 count=$(awk -v pat="$pattern" 'tolower($0) ~ tolower(pat) {n++} END {print n+0}' "$O/events.txt")
 printf '%s{"id":"%s","matching_lines":%s}' "$sep" "$kind" "$count" >> "$O/report.json"; sep=,
 done
 printf ']}\n' >> "$O/report.json"
 cp "$O/report.json" "$B/report.json.tmp" && mv "$B/report.json.tmp" "$B/report.json"
 echo "Report completed: $O";;
 *) echo 'Unknown command' >&2; exit 2;;
esac
