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
alias git-fix-perm='git diff -p -R --no-ext-diff --no-color | grep -E "^(diff|(old|new) mode)" --color=never | git apply'
alias ga="git add"
alias gap="git add -p"
alias gc="git commit -v"
alias gco="git checkout"
alias gcr="git clone --recursive"
alias gd="git diff"
alias gg="git grep"
alias gst="git status"
alias uch="git fetch && git checkout ci-update-changelog-next-release && vi debian/changelog && git add -u && git commit -m 'Update changelog' && git push origin ci-update-changelog-next-release && git checkout master && git branch -D ci-update-changelog-next-release"

# utils
alias bbat='bat --style=plain'
alias changelog-version="head -n 1 debian/changelog | cut -d' ' -f2  | cut -d'-' -f1 | cut -d'(' -f2"
alias clean-python-cache='find . | grep -E "(__pycache__|\.pyc|\.pyo$)" | xargs rm -rf'
alias fix-pycharm="ibus-daemon -rd"
alias fix-scroll-history="tput rmcup "
alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

# show permissions using numeric notation
lso() { ls -l "$@" | awk '{k=0;for(i=0;i<=8;i++)k+=((substr($1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(" %0o ",k);print}'; }
