# Generated integration scripts live outside the Stow package. env.nu runs before
# config.nu is parsed, so Atuin is available even on the first launch.
if $nu.is-interactive and (which atuin | is-not-empty) {
    mkdir $nu.cache-dir
    ^atuin init nu | save --force ($nu.cache-dir | path join atuin.nu)
}
