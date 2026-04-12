#!/bin/sh
input=$(cat)

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

parts=""

if [ -n "$used" ]; then
  parts="ctx:$(printf '%.0f' "$used")%"
fi

if [ -n "$five" ]; then
  resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
  if [ -n "$resets_at" ]; then
    now=$(date +%s)
    remaining_secs=$((resets_at - now))
    if [ "$remaining_secs" -gt 0 ]; then
      remaining_mins=$((remaining_secs / 60))
      remaining_hrs=$((remaining_mins / 60))
      remaining_min_part=$((remaining_mins % 60))
      time_left="${remaining_hrs}h${remaining_min_part}m"
    else
      time_left="resetting"
    fi
    parts="$parts 5h:$(printf '%.0f' "$five")%(${time_left})"
  else
    parts="$parts 5h:$(printf '%.0f' "$five")%"
  fi
fi

if [ -n "$week" ]; then
  parts="$parts 7d:$(printf '%.0f' "$week")%"
fi

printf "%s" "$parts"
