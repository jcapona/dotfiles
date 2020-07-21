# systemd
alias sstatus='sudo systemctl status'
alias sstart='sudo systemctl start'
alias sstop='sudo systemctl stop'
alias srestart='sudo systemctl restart'
alias senable='sudo systemctl enable'
alias sdisable='sudo systemctl disable'

# ls
alias l='ls'
alias la='ls -a'
alias ll='ls -lah'
alias ls='ls --color=auto'

# git
alias gc="git commit -v"
alias gst="git status"
alias gap="git add -p"
alias gd="git diff"
alias gcr="git clone --recursive"
alias fix-git-perm='git diff -p -R --no-ext-diff --no-color | grep -E "^(diff|(old|new) mode)" --color=never | git apply'

# utils
alias bbat='bat --style=plain'
alias fix-pycharm="ibus-daemon -rd"
alias fix-scroll-history="tput rmcup "
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'
alias changelog-version="head -n 1 debian/changelog | cut -d' ' -f2  | cut -d'-' -f1 | cut -d'(' -f2"
