#!/bin/bash
current_mode=$(swaymsg -t get_bar_config topbar | jq -r .mode)
if [ "$current_mode" = "invisible" ]; then
    swaymsg bar topbar mode dock
else
    swaymsg bar topbar mode invisible
fi

