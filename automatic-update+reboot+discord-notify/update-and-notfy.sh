#!/bin/bash
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/1304883994697007116/VWPPRNXbSIvZFpofx7xKfNJUe297tIv5hEzYTkLeDUL6gjI6hmdlZ6t20OhP2niwdm7R"
FOOTER_ICON_URL="https://cdn.discordapp.com/avatars/1289365690146492418/98bfb892f06a3cb19e3be0dbd412de16.png?size=4096"
FOOTER_NAME="System Update Script"
send_discord_embed() {
    local title="$1"
    local description="$2"
    local color="$3"
    local fields="$4"

    if [[ -z "$fields" ]]; then
        fields="[]"
    fi

    payload=$(printf '{
        "embeds": [{
            "title": "%s",
            "description": "%s",
            "color": %d,
            "fields": %s,
            "footer": {
                "text": "%s",
                "icon_url": "%s"
            },
            "timestamp": "%s"
        }]
    }' "$title" "$description" "$color" "$fields" "$FOOTER_NAME" "$FOOTER_ICON_URL" "$(date -Iseconds)")

    curl -H "Content-Type: application/json" -X POST -d "$payload" $DISCORD_WEBHOOK_URL
}

send_discord_embed "🔧 System update started" "The update script was started on $(hostname)." 3447003 "[]"

updates=""
upgrades=""
dist_upgrades=""

updates=$(sudo apt-get update -y 2>&1)
upgrades=$(sudo apt-get upgrade -y 2>&1)
dist_upgrades=$(sudo apt-get dist-upgrade -y 2>&1)

if [[ $upgrades == *"0 upgraded"* ]]; then
    send_discord_embed "✅ System update completed" "No package has been updated." 3066993 "[]"
else
    IFS=$'\n' read -rd '' -a upgrade_lines <<< "$upgrades"
    embed_fields=""
    embed_count=0

    for line in "${upgrade_lines[@]}"; do
        if [[ ${#embed_fields} -ge 1000 ]]; then
            send_discord_embed "⚠️ System update information (Part $((++embed_count)))" "The output of the upgrade is longer than expected." 15105570 "$embed_fields"
            embed_fields=""
        fi
        line_escaped=$(echo "$line" | sed 's/"/\\"/g' | sed 's/\//\\\//g')
        embed_fields="${embed_fields}, {\"name\": \"Update Zeile\", \"value\": \"\`\`\`$line_escaped\`\`\`\", \"inline\": false}"
    done

    if [[ -n $embed_fields ]]; then
        send_discord_embed "✅ System update completed" "Packages have been updated." 3066993 "$embed_fields"
    fi
fi

cleanup=$(sudo apt-get autoremove -y 2>&1 && sudo apt-get autoclean -y 2>&1 && sudo apt-get clean 2>&1)
send_discord_embed "🧹 System-Cleanup" "The system was cleaned." 15105570 "[{\"name\": \"Cleanup results\", \"value\": \"\`\`\`$cleanup\`\`\`\", \"inline\": false}]"

send_discord_embed "🔄 System Rebooted" "The system will now reboot." 15158332 "[]"

sudo reboot now
