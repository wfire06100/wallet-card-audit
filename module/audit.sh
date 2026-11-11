#!/system/bin/sh
umask 077
MODDIR=${0%/*}
BASE=/data/adb/wallet-card-audit
CMD=${1:-start}
mkdir -p "$BASE" || exit 1
LOCK="$BASE/.capture.lock"
PIDFILE="$BASE/capture.pid"
stop_capture() {
  if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE" 2>/dev/null)
    [ -n "$PID" ] && kill "$PID" 2>/dev/null
    rm -f "$PIDFILE"
  fi
  rmdir "$LOCK" 2>/dev/null
  echo 'Audit arrete.'
}
case "$CMD" in
  stop) stop_capture; exit 0 ;;
  status)
    if [ -f "$PIDFILE" ]; then echo "Audit actif (PID $(cat "$PIDFILE"))."; else echo 'Audit inactif.'; fi
    exit 0
    ;;
  start) ;;
  *) echo 'Usage: audit.sh start|stop|status'; exit 2 ;;
esac
if ! mkdir "$LOCK" 2>/dev/null; then echo 'Une capture est deja active.'; exit 1; fi
OUT="$BASE/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT" || exit 1
RAW="$OUT/.capture.tmp"
{
  date -u '+%FT%TZ'
  echo "trigger=manual_or_wallet_foreground"
  echo "android=$(getprop ro.build.version.release)"
  echo "sdk=$(getprop ro.build.version.sdk)"
  echo "security_patch=$(getprop ro.build.version.security_patch)"
  echo "wallet=$(pm list packages --show-versioncode com.google.android.apps.walletnfcrel 2>/dev/null)"
  echo "gms=$(pm list packages --show-versioncode com.google.android.gms 2>/dev/null)"
  echo "nfc_default=$(settings get secure nfc_payment_default_component 2>/dev/null)"
  echo "private_dns=$(settings get global private_dns_mode 2>/dev/null)"
  echo "airplane=$(settings get global airplane_mode_on 2>/dev/null)"
} > "$OUT/context.txt" 2>&1
echo "$$" > "$PIDFILE"
echo 'Capture activee. Reproduisez le probleme dans Wallet.'
logcat -b main -b system -b crash -v threadtime -T 1 > "$RAW" 2> "$OUT/capture-errors.txt" &
CAP_PID=$!
trap 'kill "$CAP_PID" 2>/dev/null; wait "$CAP_PID" 2>/dev/null; rm -f "$PIDFILE"; rmdir "$LOCK" 2>/dev/null; exit 0' EXIT INT TERM HUP
wait "$CAP_PID"
CAP_PID=
grep -Ei 'wallet|tapandpay|tap.and.pay|tokeniz|provision|attest|keystore|keymint|keymaster|strongbox|nfc|SSLHandshakeException|UnknownHostException|FATAL EXCEPTION' "$RAW" \
| sed -E 's/[0-9]{6,}/[REDACTED_NUMBER]/g; s/[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}/[REDACTED_EMAIL]/g; s/(Bearer|bearer) [^ ]+/Bearer [REDACTED]/g' \
> "$OUT/events.txt"
rm -f "$RAW"
REPORT="$OUT/report.json"
printf '{"schema":3,"generated_at":"%s","outcome":"unknown","findings":[' "$(date -u +%FT%TZ)" > "$REPORT"
SEP=
finding() {
  ID=$1; TITLE=$2; SEVERITY=$3; PATTERN=$4; ADVICE=$5
  COUNT=$(grep -Eic "$PATTERN" "$OUT/events.txt" 2>/dev/null)
  STATUS=not_observed; [ "$COUNT" -gt 0 ] && STATUS=observed
  printf '%s{"id":"%s","title":"%s","status":"%s","severity":"%s","matches":%s,"advice":"%s"}' "$SEP" "$ID" "$TITLE" "$STATUS" "$SEVERITY" "$COUNT" "$ADVICE" >> "$REPORT"
  SEP=,
}
finding attestation 'Attestation appareil' error 'attest.*(fail|error|reject)|(fail|error|reject).*attest' 'Verifier Play Protect, la certification appareil et les contraintes d integrite.'
finding keystore 'Keystore / StrongBox' error '(keystore|keymint|keymaster|strongbox).*(fail|error|exception)' 'Verifier les journaux Keystore/KeyMint et l integrite du TEE.'
finding network 'Reseau / VPN' warning 'SSLHandshakeException|UnknownHostException|SocketTimeoutException|ConnectException' 'Desactiver temporairement VPN, Private DNS ou filtrage DNS pour un test controle.'
finding provisioning 'Provisioning / tokenization' error '(tokeniz|provision|tapandpay).*(fail|error|exception|declin)' 'Comparer avec une autre carte ou reessayer plus tard; verifier aussi les contraintes de la banque.'
finding crash 'Crash applicatif' error 'FATAL EXCEPTION' 'Consulter les premieres lignes du crash dans events.txt.'
printf '],"interpretation":"Heuristic signals only. No observed signal does not establish success; server-side causes may remain unknown."}\n' >> "$REPORT"
mkdir -p "$MODDIR/webroot/data" 2>/dev/null
cp "$REPORT" "$MODDIR/webroot/data/report.json" 2>/dev/null || true
chmod 644 "$MODDIR/webroot/data/report.json" 2>/dev/null || true
rm -f "$PIDFILE"; rmdir "$LOCK" 2>/dev/null
echo "Audit termine. Rapport : $OUT"
