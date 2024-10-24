HYPRLAND_DEVICE="ite-tech.-inc.-ite-device(8258)-keyboard"
HYPRLAND_VARIABLE="device['$HYPRLAND_DEVICE']:enabled "

if [ -z "$XDG_RUNTIME_DIR" ]; then
  export XDG_RUNTIME_DIR=/run/user/$(id -u)
fi

export STATUS_FILE="$XDG_RUNTIME_DIR/keyboard.status"

enable_keyboard() {
  printf "true" >"$STATUS_FILE"
  notify-send -u normal "Enabling Keyboard"
  hyprctl keyword $HYPRLAND_VARIABLE "true" -r
}

disable_keyboard() {
  printf "false" >"$STATUS_FILE"
  notify-send -u normal "Disabling Keyboard"
  hyprctl keyword $HYPRLAND_VARIABLE false -r
}

if ! [ -f "$STATUS_FILE" ]; then
  enable_keyboard
else
  if [ $(cat "$STATUS_FILE") = "true" ]; then
    disable_keyboard
  elif [ $(cat "$STATUS_FILE") = "false" ]; then
    enable_keyboard
  fi
fi
