# vim: ft=fish

ssh-add -l | grep -q id_rsa; or ssh-add $HOME/.ssh/id_rsa

fish_add_path $HOME/.krew/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin

set -x GOBIN $HOME/.local/bin

if set -q SSH_CONNECTION
    alias c='printf "\033]52;c;$(base64 -w0)\033\\"'
else
    alias c='pbcopy'
end

alias k=kubectl
alias ls='ls -G'
alias ll='ls -lh'
alias s=systemctl
alias vim=nvim
alias g=git
alias controller-runtime='cd $HOME/git/go/src/sigs.k8s.io/controller-runtime'
alias brew=/opt/homebrew/bin/brew

set -x SYSTEMD_PAGER
set -x CGO_ENABLED 0
set -x EDITOR nvim

kubectl completion fish | sed 's/kubectl/k/g' | source -

if not test -e ~/.git-auto-complete.fish
    curl --fail -L https://raw.githubusercontent.com/fish-shell/fish-shell/master/share/completions/git.fish > ~/.git-auto-complete.fish
end
source ~/.git-auto-complete.fish

function mkcd
    mkdir -p $argv[1]; and cd $argv[1]
end

if command -q cargo
    command -q kube-switch; or cargo install --git https://github.com/alvaroaleman/kube-switch.git
		kube-switch completion fish|source -
end

starship init fish | source

test -r ~/.config/fish/config_local.fish; and source ~/.config/fish/config_local.fish

test -f "$HOME/.cargo/env.fish"; and source "$HOME/.cargo/env.fish"

# Disable annoying default greeting
set -U fish_greeting ""
