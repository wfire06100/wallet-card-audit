#!/system/bin/sh
[ -f "$1" ] || exit 2
D=${0%/*}
. "$D/network-patterns.sh" || exit 1
network=0
[ ! -f /data/adb/wallet-card-audit/network-enabled ] || network=1
awk -v network="$network" -v netpat="$NETWORK_PATTERN" '
{
 line=tolower($0)
 if(line ~ /^[0-9-]+[[:space:]]+[0-9:.]+[[:space:]]+[0-9]+[[:space:]]+[0-9]+[[:space:]]+[vdiwef][[:space:]]+(ksuwebui|ksuwebuistandalone|walletcardaudit|wallet-card-audit)[[:space:]]*:/) next
 if(network && line ~ netpat) print
 else if(line ~ /teesimulator|keymintsecuritylevelinterceptor|systemlogger|softwareoperation|operationinterceptor|createoperation|generatekey|importkey|post-importkey|authorizecreate|keyid|not found|forwarding to hal|generating software key|creating software operation|found new ikeystoreoperation|registering interceptor|restoring persisted key|failed to restore key|failed to restore symmetric metadata|keymint_finish_operation|verification_failed|failed to create encrypteddata|txid|keystore|keymint|keymaster|strongbox|tapandpay|tap.and.pay|tokeniz|networkmonitor|sslhandshakeexception|unknownhostexception|sockettimeoutexception|fatal exception/) print
 else if(line ~ /[[:space:]]pay[[:space:]]*:/) print
}' "$1" | sed -E 's/[0-9]{13,19}/[LONG_NUMBER]/g;s/[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}/[EMAIL]/g;s/[Bb]earer [^ ]+/Bearer [TOKEN]/g'
