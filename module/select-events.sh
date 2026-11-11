#!/system/bin/sh
[ -f "$1" ] || exit 2
awk '
{
 line=tolower($0)
 if(line ~ /^[0-9-]+[[:space:]]+[0-9:.]+[[:space:]]+[0-9]+[[:space:]]+[0-9]+[[:space:]]+[vdiwef][[:space:]]+(ksuwebui|ksuwebuistandalone|walletcardaudit|wallet-card-audit)[[:space:]]*:/) next
 if(line ~ /keymintsecuritylevelinterceptor|systemlogger|softwareoperation|operationinterceptor|createoperation|generatekey|authorizecreate|creating software operation|found new ikeystoreoperation|registering interceptor|restoring persisted key|failed to restore key|failed to restore symmetric metadata|txid|keystore|keymint|keymaster|strongbox|tapandpay|tap.and.pay|tokeniz|networkmonitor|sslhandshakeexception|unknownhostexception|sockettimeoutexception|fatal exception/) print
 else if(line ~ /[[:space:]]pay[[:space:]]*:/) print
}' "$1" | sed -E 's/[0-9]{13,19}/[LONG_NUMBER]/g;s/[[:alnum:]._%+-]+@[[:alnum:].-]+\.[[:alpha:]]{2,}/[EMAIL]/g;s/[Bb]earer [^ ]+/Bearer [TOKEN]/g'
