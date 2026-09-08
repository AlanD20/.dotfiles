# FZF selections use NUL delimiters to preserve spaces/newlines in filenames.
def --wrapped fzf-pick [...args: string] {
    let result = ($in | ^fzf --read0 --print0 ...$args | complete)
    if $result.exit_code in [1 130] { return null }
    if $result.exit_code != 0 { error make {msg: $result.stderr} }
    $result.stdout | split row (char nul) | where {|p| $p != '' } | get -o 0
}
def fp [] {
    ^rg --files --hidden --glob '!{.git,.cache}' --null
    | fzf-pick --preview 'bat --color=always --style=plain -- {}'
}
def vfp [] { let file = (fp); if ($file | is-not-empty) { ^nvim -- $file } }
def vfd [] {
    let file = (^fd . --type f --print0 | fzf-pick)
    if ($file | is-not-empty) { ^nvim -- $file }
}
def --env cdf [] {
    let dir = (^fd . --type d --print0 | fzf-pick --preview 'eza -a --icons -- {}')
    if ($dir | is-not-empty) { cd $dir }
}
def fzf-insert-file [] {
    let file = (fp)
    # A JSON string is also a valid quoted Nu string; no interpolation/evaluation.
    if ($file | is-not-empty) { commandline edit --insert ($file | to json --raw) }
}
def --env econf [] { cd $env.DOTFILES; ^nvim }
# Start a fresh process so integration hooks are not registered twice.
def rr [] { exec $nu.current-exe }
def gfo [branch: string] { ^git fetch origin $'($branch):($branch)' }
def clone_single_branch [branch: string, repository: string, ...rest: string] {
    ^git clone --single-branch --branch $branch $repository ...$rest
}
def fetch_origin_branch [branch: string] { gfo $branch }
def tgpg [] { 'test' | ^gpg --clearsign }
def viewdoc [file: path] { ^mupdf -I $file }
def viewimg [file: path] { ^feh $file }
def jqq [file: path] { ^jqp -t dracula -f $file }
def jql [filter: string = '.'] { $in | ^jq -R -r ($filter + ' as $line | try fromjson catch $line') }
def dssh [container: string, user: string = 'root', command: string = '/bin/bash'] {
    ^docker exec --user $user -it $container $command
}
def --env f [...args: string] {
    ^fff ...$args
    let last_dir = ($env.XDG_CACHE_HOME | path join fff .fff_d)
    if ($last_dir | path exists) { cd (open --raw $last_dir | str trim --right) }
}
def keepass [] { job spawn { ^keepassxc } }
# The Zsh alias contains `&&-` and `artisan clear`; use valid Laravel commands
# and stop at the first failure rather than continuing with partial results.
def pa-clear [] {
    for command in [clear-compiled config:clear cache:clear view:clear route:clear optimize] {
        ^php artisan $command
        if $env.LAST_EXIT_CODE != 0 { error make {msg: $'artisan ($command) failed'} }
    }
    ^composer dump-autoload -o
}

# NVM is a Bash function. Pass arguments directly, and import only its Node path.
# This preserves the existing NVM installation, default alias and .nvmrc support.
def --env --wrapped nvm [...args: string] {
    let result = (^bash --noprofile --norc -c '
        . "$NVM_DIR/nvm.sh" --no-use || exit
        nvm "$@" >&2 || exit
        printf "%s" "${NVM_BIN-}"
    ' nvm ...$args | complete)
    if ($result.stderr | is-not-empty) { print --stderr --no-newline $result.stderr }
    if $result.exit_code != 0 { error make {msg: 'nvm failed; Node selection was preserved'} }
    let node_bin = $result.stdout
    $env.PATH = ($env.PATH | where {|p| not ($p | str starts-with ($env.NVM_DIR + '/versions/node/')) })
    if ($node_bin | is-not-empty) {
        $env.NVM_BIN = $node_bin
        $env.PATH = ($env.PATH | prepend $node_bin | uniq)
    } else { hide-env -i NVM_BIN }
}

# Reuse rupa/z's ranking and ~/.z database rather than start a second database.
def --env --wrapped z [...args: string] {
    let script = ($env.XDG_DATA_HOME | path join zinit plugins rupa---z z.sh)
    let result = (^bash --noprofile --norc -c '
        . "$1" || exit
        shift
        _z "$@" >&2 || exit
        printf "%s" "$PWD"
    ' z $script ...$args | complete)
    if ($result.stderr | is-not-empty) { print --stderr --no-newline $result.stderr }
    if $result.exit_code != 0 { error make {msg: 'z could not find a matching directory'} }
    cd $result.stdout
}
