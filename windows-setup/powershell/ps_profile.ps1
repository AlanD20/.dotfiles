Import-Module posh-git
Import-Module oh-my-posh
Set-Theme Paradox

function Refresh-GPG {
	echo "test" | gpg --clearsign
}

Set-Alias rr Refresh-GPG
