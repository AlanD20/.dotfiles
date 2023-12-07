oh-my-posh init pwsh --config 'https://raw.githubusercontent.com/AlanD20/.dotfiles/main/oh-my-posh/.config/oh-my-posh/themes/aland20-custom-theme.omp.json' | Invoke-Expression

function Refresh-GPG {
	echo "test" | gpg --clearsign
}

Set-Alias rr Refresh-GPG
Set-Alias lz lazygit
