#!/bin/bash

logger(){

    # derive log file path and name from LOGFILEPATH if provided
    local log_file_path
    local log_file_name

    if [ -n "${LOGFILEPATH:-}" ]; then
        log_file_path="$(dirname "${LOGFILEPATH}")"
        log_file_name="$(basename "${LOGFILEPATH}")"
    else
        log_file_path="./logs"
        log_file_name="script.log"
    fi

    mkdir -p "${log_file_path}"

    # Usage: logger <SEVERITY> <LOG_MESSAGE>
    # Example: logger "INFO" "some message"
    # Severity Levels: DEBUG, INFO, WARNING, ERROR, EXCEPTION, CRITICAL
    local severity
    local log_message

    if [ $# -eq 2 ]; then
        severity="$1"
        log_message="$2"
    elif [ $# -eq 1 ]; then
        severity="INFO"
        log_message="$1"
    else
        severity="EXCEPTION"
        log_message="Wrong syntax used for logger function. Usage: logger <SEVERITY> <LOG_MESSAGE>"
    fi

    printf '%s %s: %s\n' "$(date '+%Y-%m-%d %T')" "$severity" "$log_message" >> "${log_file_path}/${log_file_name}"
}
