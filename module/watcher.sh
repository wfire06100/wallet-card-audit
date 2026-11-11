#!/system/bin/sh
D=${0%/*}; B=/data/adb/wallet-card-audit
echo $$ > "$B/watcher.pid"
trap 'exit 0' TERM INT HUP
own=false; miss=0
while :; do
 top=$(dumpsys activity activities 2>/dev/null | grep -E 'topResumedActivity|mResumedActivity' | head -n 1)
 if echo "$top" | grep -q 'com.google.android.apps.walletnfcrel'; then
 miss=0
 if [ ! -d "$B/lock" ]; then /system/bin/sh "$D/engine.sh" start && own=true; fi
 else
 miss=$((miss+1))
 if [ "$own" = true ] && [ "$miss" -ge 5 ]; then /system/bin/sh "$D/engine.sh" stop; own=false; fi
 fi
 sleep 2
done
