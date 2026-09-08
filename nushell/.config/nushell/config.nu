# Nushell 0.115+: keep defaults, override only our preferences.
source environment.nu
$env.config.show_banner = false
$env.config.edit_mode = 'emacs'
$env.config.buffer_editor = 'nvim'
$env.config.history.file_format = 'sqlite'
$env.config.history.max_size = 10000
$env.config.history.sync_on_enter = true
$env.config.history.isolation = false
$env.config.history.ignore_space_prefixed = true
$env.config.completions.case_sensitive = true
$env.config.completions.algorithm = 'fuzzy'
$env.config.color_config.hints = 'dark_gray'
$env.config.table.mode = 'rounded'

# Optional external completions; native completion works without Carapace.
if (which carapace | is-not-empty) {
    $env.config.completions.external.completer = {|spans|
        let result = (^carapace $spans.0 nushell ...$spans | complete)
        if $result.exit_code == 0 { $result.stdout | from json } else { null }
    }
}
source aliases.nu
source helpers.nu

$env.config.keybindings ++= [
    {name: shift_left, modifier: shift, keycode: left, mode: emacs, event: {edit: movewordleft}}
    {name: shift_right, modifier: shift, keycode: right, mode: emacs, event: {edit: movewordright}}
    {name: edit_command, modifier: control, keycode: char_o, mode: emacs, event: {send: openeditor}}
    {name: find_file, modifier: control, keycode: char_t, mode: emacs, event: {send: executehostcommand, cmd: 'fzf-insert-file'}}
    {name: find_directory, modifier: alt, keycode: char_c, mode: emacs, event: {send: executehostcommand, cmd: 'cdf'}}
]

# Atuin supplies Ctrl-R and Up with the same config/database as Zsh.
source (if (($nu.cache-dir | path join atuin.nu) | path exists) {
    $nu.cache-dir | path join atuin.nu
})
# Record directory changes using the same locking/ranking implementation as Zsh.
if (($env.XDG_DATA_HOME | path join zinit plugins rupa---z z.sh) | path exists) {
    $env.config.hooks.env_change.PWD = (($env.config.hooks.env_change.PWD? | default []) ++ [{|before, after|
        ^bash --noprofile --norc -c '. "$1"; _z --add "$2"' z (
            $env.XDG_DATA_HOME | path join zinit plugins rupa---z z.sh
        ) $after | complete | ignore
    }])
}

# Reuse the inherited NVM selection; standalone shells load the default version.
if (($env.NVM_DIR | path join nvm.sh) | path exists) and (($env.NVM_BIN? | is-empty) or not (($env.NVM_BIN | path join node) | path exists)) {
    try { nvm use --silent default } catch {|err| print --stderr $err.msg }
}
if (which gpgconf | is-not-empty) { ^gpgconf --launch gpg-agent | complete | ignore }
if (which fastfetch | is-not-empty) { do --ignore-errors { ^fastfetch } }
if (which oh-my-posh | is-not-empty) {
    ^oh-my-posh init nu --config ($env.XDG_CONFIG_HOME | path join oh-my-posh themes aland20-custom-theme.omp.json)
}
