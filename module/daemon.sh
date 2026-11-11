#!/system/bin/sh
case "${1:-status}" in
 toggle) exec /system/bin/sh "${0%/*}/engine.sh" auto-toggle;;
 stop) exec /system/bin/sh "${0%/*}/engine.sh" shutdown;;
 *) exec /system/bin/sh "${0%/*}/engine.sh" status;;
esac
