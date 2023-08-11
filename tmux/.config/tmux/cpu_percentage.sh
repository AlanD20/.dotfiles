show_cpu_percentage() {
  local index=$1
  local icon="$(get_tmux_option "@catppuccin_cpu_percentage_icon" "󰘚")"
  local color="$(get_tmux_option "@catppuccin_cpu_percentage_color" "#ff7a93")"
  local text="$(get_tmux_option "@catppuccin_cpu_percentage_text" "#{cpu_percentage}")"

  local module=$(build_status_module "$index" "$icon" "$color" "$text")

  echo $module
}
