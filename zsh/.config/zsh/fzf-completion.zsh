# Loaded after fzf so its host discovery remains the portable fallback.
# fd respects ignore files, unlike fzf's built-in walker. WSL distributions
# sometimes package it as fdfind. Without either, retain fzf's native traversal.
if (( $+commands[fd] || $+commands[fdfind] )); then
  _fzf_compgen_path() {
    command zsh -f "$ZDOTDIR/fzf-candidates.zsh" list path "$1" normal
  }
  _fzf_compgen_dir() {
    command zsh -f "$ZDOTDIR/fzf-candidates.zsh" list dir "$1" normal
  }
fi

if (( $+functions[__fzf_list_hosts] && ! $+functions[_dotfiles_fzf_list_hosts] )); then
  functions -c __fzf_list_hosts _dotfiles_fzf_list_hosts
  __fzf_list_hosts() {
    {
      # Prefer literal aliases in config order; wildcard/negated patterns are
      # rules, not destinations. Keep upstream discovery for known_hosts, etc.
      command awk '
        tolower($1) == "host" {
          for (i = 2; i <= NF && $i !~ /^#/; i++)
            if ($i !~ /[!*?%]/) print $i
        }
      ' "$HOME/.ssh/config" "$HOME"/.ssh/config.d/*(N.) /etc/ssh/ssh_config 2>/dev/null
      _dotfiles_fzf_list_hosts
    } | command awk '!seen[$0]++'
  }
fi

_fzf_comprun() {
  local cmd=$1
  shift
  local mode=path label='Complete > '
  local -a words runner
  words=(${(z)LBUFFER})
  case $cmd in
    ssh)
      case ${words[-2]} in
        -i|-F|-E) mode=metadata; label='SSH file > ' ;;
        *) mode=ssh; label='SSH host > ' ;;
      esac
      ;;
    cd) label='Directory > ' ;;
    export|unset|unalias|kill|telnet)
      # These candidates are not files. Preserve their upstream previews.
      mode=none
      ;;
  esac

  runner=(fzf)
  if [[ -n ${TMUX_PANE-} ]] && [[ ${FZF_TMUX:-0} != 0 || -n ${FZF_TMUX_OPTS-} ]]; then
    if [[ -n ${FZF_TMUX_OPTS-} ]]; then
      runner=(fzf-tmux ${(Q)${(Z+n+)FZF_TMUX_OPTS}} --)
    else
      runner=(fzf-tmux -d "${FZF_TMUX_HEIGHT:-40%}" --)
    fi
  fi
  if [[ $mode == none ]]; then
    command "${runner[@]}" "$@"
  else
    local preview="zsh -f ${(q)ZDOTDIR}/fzf-preview.zsh $mode {}"
    local header='Enter: select | Ctrl-/: preview | Esc: cancel'
    local -a traversal_opts
    # fzf's path-completion function exposes the resolved root and generator
    # through Zsh's dynamic scope. Do not replace SSH hosts or custom candidates.
    if [[ ${compgen-} == _fzf_compgen_path || ${compgen-} == _fzf_compgen_dir ]] &&
       (( $+commands[fd] || $+commands[fdfind] )); then
      local kind=path
      [[ $compgen == _fzf_compgen_dir ]] && kind=dir
      label='Files > '
      [[ $kind == dir ]] && label='Directories > '
      header='Hidden: off | Ignored: off | Ctrl-G: cycle | Ctrl-/: preview'
      traversal_opts=(--bind="ctrl-g:transform:zsh -f ${(q)ZDOTDIR}/fzf-candidates.zsh cycle $kind ${(q)dir}")
    fi
    command "${runner[@]}" "$@" --prompt="$label" --tiebreak=index \
      --header="$header" "${traversal_opts[@]}" \
      --preview="$preview" --preview-window='right,50%,wrap,<80(up,40%)' \
      --bind='ctrl-/:toggle-preview'
  fi
}
