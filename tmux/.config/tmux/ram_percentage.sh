show_ram_percentage() {
  local index=$1
  local icon="$(get_tmux_option "@catppuccin_ram_percentage_icon" "󰍛 ")"
  local color="$(get_tmux_option "@catppuccin_ram_percentage_color" "#0db9d7")"
  local text="$(get_tmux_option "@catppuccin_ram_percentage_text" "#{ram_percentage}")"

  local module=$(build_status_module "$index" "$icon" "$color" "$text")

  echo $module
}
