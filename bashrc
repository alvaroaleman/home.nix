ssh-add -l|grep -q id_rsa || ssh-add ${HOME}/.ssh/id_rsa

if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

export PATH="${PATH}:${HOME}/.krew/bin"
export PATH="${HOME}/.local/bin:${PATH}"
export PATH="${HOME}/.cargo/bin:${PATH}"

export GOBIN="${HOME}/.local/bin"

if [ -n "$SSH_CONNECTION" ]; then
  alias c='printf "\033]52;c;$(base64 -w0)\033\\"'
else
  alias c='pbcopy'
fi

alias k=kubectl
source <(kubectl completion bash|sed 's/kubectl/k/g')

alias ls='ls -G'
alias ll='ls -lh'

alias s=systemctl
export SYSTEMD_PAGER=

alias vim=nvim
alias g=git

export CGO_ENABLED=0
export EDITOR=nvim

alias controller-runtime='cd $HOME/git/go/src/sigs.k8s.io/controller-runtime'

# Append to the history file, don't overwrite it
shopt -s histappend

# Save multi-line commands as one command
shopt -s cmdhist

# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Avoid duplicate entries in history
export HISTCONTROL="erasedups:ignoreboth"
# Ignore some commands for history recording
export HISTIGNORE="exit:ls:bg:fg:history:l"

if [[ $- == *i* ]] && [[ -t 0 ]]; then
	bind "set completion-ignore-case on"
	bind "set show-all-if-ambiguous on"
fi

if ! [[ -e ~/.git-auto-complete.bash ]]; then
        curl --fail -L https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash > ~/.git-auto-complete.bash
fi
source <(cat ~/.git-auto-complete.bash|sed 's/git/g/g')

mkcd () {
        mkdir -p $1 && cd $1
}

PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# Force lookup of commands in the hashtable if they don't exist anymore
shopt -s checkhash

if which cargo &>/dev/null; then
				which kube-switch &>/dev/null|| cargo install --git https://github.com/alvaroaleman/kube-switch.git
				source <(kube-switch completion)
fi

eval "$(starship init bash)"

[ -r ~/.bashrc_local ] && source ~/.bashrc_local

COMP_WORDBREAKS="${COMP_WORDBREAKS//:}"

if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

alias ls='ls --color=auto'

alias brew=/opt/homebrew/bin/brew

[[ -f $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh ]] && \
  source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
