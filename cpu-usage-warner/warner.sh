#!/bin/bash

MAX=95

get_cpu_usage() {
  grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}'
}

send_email_notification() {
  local email=$1
  local usage=$2
  echo "Percent used: $usage%" | mail -s "Running out of CPU power" "$email"
}

send_discord_notification() {
  local webhook_url=$1
  local usage=$2
  curl -H "Content-Type: application/json" -X POST -d \
    '{"embeds": [{"title": "CPU Usage Alert", "description": "CPU usage is high", "fields": [{"name": "Percent Used", "value": "'"$usage"'%"}], "color": 16711680}]}' \
    "$webhook_url"
}

main() {
  echo "Select notification method:"
  echo "1) Send email notification"
  echo "2) Send Discord webhook notification"
  read -rp "Enter your choice (1 or 2): " choice

  USE=$(get_cpu_usage)

  if (( $(echo "$USE > $MAX" | bc -l) )); then
    case $choice in
      1)
        read -rp "Enter the recipient email address: " email
        send_email_notification "$email" "$USE"
        echo "Email notification sent to $email."
        ;;
      2)
        read -rp "Enter the Discord webhook URL: " webhook_url
        send_discord_notification "$webhook_url" "$USE"
        echo "Discord notification sent via webhook."
        ;;
      *)
        echo "Invalid choice. Please enter 1 or 2."
        exit 1
        ;;
    esac
  else
    echo "CPU usage is under control: ${USE}%"
  fi
}

main
