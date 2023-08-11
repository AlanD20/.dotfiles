show_cpu_temp() {
  local index=$1
  local icon="$(get_tmux_option "@catppuccin_cpu_temp_icon" "")"
  local color="$(get_tmux_option "@catppuccin_cpu_temp_color" "$thm_blue")"
  local text="$(get_tmux_option "@catppuccin_cpu_temp_text" "#{cpu_temp}")"

  local module=$(build_status_module "$index" "$icon" "$color" "$text")

  echo $module
}
