#!/system/bin/sh
exec /system/bin/sh "${0%/*}/engine.sh" "${1:-status}"
