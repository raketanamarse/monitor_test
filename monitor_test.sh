#!/bin/bash
set -euo pipefail


exec 200>/var/lock/monitor.lock
flock -n 200 || exit 0


PROCESS_NAME="btop"
MONITOR_URL="https://test.com/monitoring/test/api"
LOG_FILE="/var/log/monitoring_test.log"
STATE_FILE="/var/lib/monitoring_test.pid"


if [[ ! -f "$LOG_FILE" ]]; then
    touch "$LOG_FILE"
fi

if [[ ! -f "$STATE_FILE" ]]; then
    touch "$STATE_FILE"
fi

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_FILE"
}


pid=$(pgrep -x "$PROCESS_NAME" || true)

if [[ -n "$pid" ]]; then
    log "процесс $PROCESS_NAME работает, PID=$pid"

    old_pid=$(cat "$STATE_FILE" || true)

    if [[ "$old_pid" != "$pid" ]]; then
        log "процесс $PROCESS_NAME был перезапущен (старый PID=$old_pid, новый PID=$pid)"
    fi

    echo "$pid" > "$STATE_FILE"

else
    log "процесс $PROCESS_NAME не запущен"
fi


if ! curl -fsS -m 5 "$MONITOR_URL" > /dev/null; then
    log "сервер мониторинга недоступен: $MONITOR_URL"
fi
