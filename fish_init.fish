# vim: ft=fish

if test -f $HOME/.ssh/id_rsa
  ssh-add -l | grep -Eq 'lxYHmW8Mo6sKO8Iw3ylQ\+7S3SMZTR5ugG51Q7EMnZ60|id_rsa'; or ssh-add $HOME/.ssh/id_rsa
end

fish_add_path $HOME/.krew/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.cargo/bin
fish_add_path /usr/local/go/bin

# Installing claude through nix causes constant timeouts
# Ref https://github.com/NixOS/nixpkgs/issues/453955
fish_add_path $HOME/.npm-global/bin
mkdir -p ~/.npm-global
echo 'prefix=~/.npm-global' > ~/.npmrc
type claude &>/dev/null || npm install -g @anthropic-ai/claude-code

test -d /opt/homebrew/bin && fish_add_path /opt/homebrew/bin

set -x GOBIN $HOME/.local/bin

if set -q SSH_CONNECTION
    function c
      cat | base64 -w0 | read -z encoded
      printf "\033]52;c;%s\033\\" $encoded
    end
else if type -q pbcopy
    alias c='pbcopy'
else
    alias c='wl-copy'
end

alias k=kubectl
alias ls='ls -G --color=auto'
alias ll='ls -lh'
alias l=ll
alias s=systemctl
alias vim=nvim
alias g=git
alias brew=/opt/homebrew/bin/brew

function setup_project_aliases
    set -l configs \
        ~/git/go/src/k8s.io/ 1 \
        ~/git/go/src/sigs.k8s.io 1 \
        ~/git/go/src/github.com 2 \
        ~/git/private 1

    for i in (seq 1 2 (count $configs))
        set base_dir $configs[$i]
        set depth $configs[(math $i + 1)]

        if ! test -d $base_dir; continue; end

        for project_path in (find $base_dir -mindepth $depth -maxdepth $depth -type d)
            set project_name (basename $project_path)

            # Don't override commands
            if type -q $project_name
                continue
            end
            alias $project_name "cd $project_path"
        end
    end
end
setup_project_aliases

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

function gwt
    set -l name (openssl rand -hex 10)
    git worktree add .worktrees/$name -B $name main && cd .worktrees/$name
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

# Share history across terminals immediately
function save_history --on-event fish_postexec
    history save
end

alias unset 'set -e argv[1]'

if test -f ~/.bashrc_local; bass source ~/.bashrc_local; end

alias then='true;'

function nix-shell
    command nix-shell $argv --command fish
end

function __fish_complete_aws
    env COMP_LINE=(commandline -pc) aws_completer | tr -d ' '
end
complete -c aws -f -a "(__fish_complete_aws)"

bind \cw backward-kill-word

export TENV_AUTO_INSTALL=true

export CARGO_BUILD_JOBS=8

alias assume="bass source $HOME/.nix-profile/bin/assume"
if not test -f ~/.config/fish/completions/granted.fish
    granted completion -s fish > ~/.config/fish/completions/granted.fish
end
source ~/.config/fish/completions/granted.fish
