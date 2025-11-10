#!/bin/bash


PROCESS_NAME="btop"
MONITOR_URL="https://test.com/monitoring/test/api"
LOG_FILE="/var/log/monitoring_test.log" #"/home/1Tb/test/monitoring_test.log" 
STATE_FILE="/tmp/test_monitor.state" #"/home/1Tb/test/test_monitor.state" 
INTERVAL=60 


while true; do

    if [ ! -f "$LOG_FILE" ]; then
        touch "$LOG_FILE"
        echo "$(date '+%Y-%m-%d %H:%M:%S') создан файл лога $LOG_FILE" >> "$LOG_FILE"
    fi

    if [ ! -f "$STATE_FILE" ]; then
        touch "$STATE_FILE"
        echo "$(date '+%Y-%m-%d %H:%M:%S') создан файл состояния $STATE_FILE" >> "$LOG_FILE"
    fi


    pid=$(pgrep -x "$PROCESS_NAME")

    if [ -n "$pid" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') процесс $PROCESS_NAME работает PID=$pid" >> "$LOG_FILE"
        
        # проверка перезапуска
        if [ -f "$STATE_FILE" ]; then
            old_pid=$(cat "$STATE_FILE")
            if [ "$old_pid" != "$pid" ]; then
                echo "$(date '+%Y-%m-%d %H:%M:%S') процесс $PROCESS_NAME был перезапущен (старый PID=$old_pid, новый PID=$pid)" >> "$LOG_FILE"
            fi
        fi
        echo "$pid" > "$STATE_FILE"

        # проверка сервера мониторинга
        curl -fsS -m 5 "$MONITOR_URL" > /dev/null
        if [ $? -ne 0 ]; then
            echo "$(date '+%Y-%m-%d %H:%M:%S') сервер мониторинга недоступен $MONITOR_URL" >> "$LOG_FILE"
        fi
    else
        echo "$(date '+%Y-%m-%d %H:%M:%S') процесс $PROCESS_NAME не запущен" >> "$LOG_FILE"
    fi

    sleep "$INTERVAL"
done
