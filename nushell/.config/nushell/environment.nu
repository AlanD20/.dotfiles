# Match common/.zshenv and Zsh's development environment.
$env.XDG_CONFIG_HOME = ($env.XDG_CONFIG_HOME? | default ($nu.home-dir | path join .config))
$env.XDG_CACHE_HOME = ($env.XDG_CACHE_HOME? | default ($nu.home-dir | path join .cache))
$env.XDG_DATA_HOME = ($env.XDG_DATA_HOME? | default ($nu.home-dir | path join .local share))
$env.DOTFILES = ($nu.home-dir | path join .dotfiles)
# The shared Atuin config expands ZDOTDIR to locate the existing history DB.
$env.ZDOTDIR = ($env.XDG_CONFIG_HOME | path join zsh)
$env.EDITOR = 'nvim'
$env.VISUAL = 'nvim'
$env.CARGO_HOME = ($env.XDG_DATA_HOME | path join cargo)
$env.RUSTUP_HOME = ($env.XDG_DATA_HOME | path join rustup)
$env.BUN_INSTALL = ($env.XDG_DATA_HOME | path join bun)
$env.NVM_DIR = ($env.XDG_DATA_HOME | path join nvm)
$env.PYENV_ROOT = ($nu.home-dir | path join .pyenv)
$env.RBENV_ROOT = ($env.RBENV_ROOT? | default ($nu.home-dir | path join .rbenv))
$env.PATH = ([
    ($env.PYENV_ROOT | path join shims)
    ($env.PYENV_ROOT | path join bin)
    ($env.RBENV_ROOT | path join shims)
    ($env.RBENV_ROOT | path join bin)
    ($env.BUN_INSTALL | path join bin)
    ($env.CARGO_HOME | path join bin)
    '/opt/homebrew/bin'
    '/opt/homebrew/sbin'
] | where {|p| $p | path exists } | append $env.PATH | append [
    ($nu.home-dir | path join .local bin)
    ($env.XDG_DATA_HOME | path join nvim mason bin)
] | uniq)
$env.LANGUAGE = 'en_US.UTF-8'
$env.LANG = 'en_US.UTF-8'
$env.LC_ALL = 'en_US.UTF-8'
$env.BAT_THEME = 'ansi'
$env.GO11MODULE = 'on'
$env.YAMLFIX_LINE_LENGTH = '140'
$env.YAMLFIX_COMMENTS_REQUIRE_STARTING_SPACE = 'true'
$env.YAMLFIX_EXPLICIT_START = 'false'
$env.YAMLFIX_SEQUENCE_STYLE = 'keep_style'
$env.YAMLFIX_quote_basic_values = 'false'
$env.YAMLFIX_quote_representation = '"'
$env.YAMLFIX_COMMENTS_WHITELINES = '1'
$env.YAMLFIX_preserve_quotes = 'true'
$env.FZF_DEFAULT_COMMAND = "rg --files --hidden --glob '!{.git,.cache}'"
$env.FZF_DEFAULT_OPTS = '--height=65% --layout=reverse --border --margin=1 --padding=1'
# fzf executes preview commands in a POSIX shell, even when called from Nu.
$env.FZF_DEFAULT_OPTS = $env.FZF_DEFAULT_OPTS + ' --with-shell="bash -c"'
$env.FFF_FAV1 = ($nu.home-dir | path join dev)
$env.FFF_FAV2 = ($nu.home-dir | path join temp)
$env.FFF_FAV3 = ($nu.home-dir | path join .local bin)
$env.FFF_FAV4 = $env.DOTFILES
$env.FFF_FAV9 = '/'
if ($env.TERM? | default '') == 'xterm' { $env.TERM = 'xterm-256color' }
if $nu.os-info.name == 'linux' and ($env.XDG_RUNTIME_DIR? | is-not-empty) {
    $env.SSH_AUTH_SOCK = ($env.XDG_RUNTIME_DIR | path join ssh-agent.socket)
}
if (which tty | is-not-empty) {
    let terminal = (^tty | complete)
    if $terminal.exit_code == 0 { $env.GPG_TTY = ($terminal.stdout | str trim) }
}
