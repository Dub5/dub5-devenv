# Environment variables
export PS1="[\[\033[1;34m\]\u\[\033[0m\]@\h:\[\033[1;37m\]\w\[\033[0m\]]$ "
alias l="ls -lAhG"
alias ls="ls -G"
alias ll="ls -lAhG"
alias dir="ll"
alias cls="clear"
# Load secret keys, if any
if [ -f ~/.secret_keys.sh ]; then
  source ~/.secret_keys.sh
fi
