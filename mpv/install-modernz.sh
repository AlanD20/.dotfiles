#!/usr/bin/env bash
# Install ModernZ for mpv. Usage: ./install-modernz.sh [linux|macos]
set -euo pipefail

case "${1:-$(uname -s)}" in
    Linux|linux) mpv_dir="$HOME/.config/mpv" ;;
    # Homebrew mpv uses the XDG config directory on macOS as well.
    Darwin|macos) mpv_dir="${XDG_CONFIG_HOME:-$HOME/.config}/mpv" ;;
    *) echo "Usage: $0 [linux|macos]" >&2; exit 1 ;;
esac

command -v curl >/dev/null || { echo "curl is required" >&2; exit 1; }
if command -v shasum >/dev/null; then
    hash_command=(shasum -a 256)
elif command -v sha256sum >/dev/null; then
    hash_command=(sha256sum)
else
    echo "shasum or sha256sum is required" >&2
    exit 1
fi

version=v0.3.3
base_url="https://github.com/Samillion/ModernZ/releases/download/$version"
temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/modernz.XXXXXXXX")
trap 'rm -rf "$temp_dir"' EXIT

download() {
    local name=$1 expected=$2 actual
    curl --fail --location --silent --show-error \
        "$base_url/$name" --output "$temp_dir/$name"
    actual=$("${hash_command[@]}" "$temp_dir/$name")
    actual=${actual%% *}
    if [ "$actual" != "$expected" ]; then
        echo "Checksum mismatch for $name" >&2
        exit 1
    fi
}

download modernz.lua c36aef0152d3fdb0c769cefe7074648b457ed50ea4ddcc402b778bec23ca32c8
download modernz-icons.ttf 5033b84d569502538968c6f23b0859bda790eed85c10e419b0759537ec60a016
download modernz.conf e730a176703eee29404b2d16dfab58bbaef368b04c1b2a37aafc2b40983388bd

mkdir -p "$mpv_dir/scripts" "$mpv_dir/fonts" "$mpv_dir/script-opts"
install -m 644 "$temp_dir/modernz.lua" "$mpv_dir/scripts/modernz.lua"
install -m 644 "$temp_dir/modernz-icons.ttf" "$mpv_dir/fonts/modernz-icons.ttf"
if [ ! -e "$mpv_dir/script-opts/modernz.conf" ]; then
    install -m 644 "$temp_dir/modernz.conf" "$mpv_dir/script-opts/modernz.conf"
fi

config="$mpv_dir/mpv.conf"
# The last osc setting wins. Keep other mpv preferences untouched.
if [ -f "$config" ]; then
    current_osc=$(sed -nE 's/^[[:space:]]*osc[[:space:]]*=[[:space:]]*([^#[:space:]]+).*/\1/p' "$config" | tail -n 1)
else
    current_osc=
fi
if [ "$current_osc" != no ]; then
    printf '\n# Use ModernZ instead of mpv\047s built-in controls.\nosc=no\n' >> "$config"
fi

echo "ModernZ $version installed in $mpv_dir (restart mpv to use it)."
