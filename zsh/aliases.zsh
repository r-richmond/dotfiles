alias reload!='. ~/.zshrc'

alias cls='clear' # Good 'ol Clear Screen command

########################
### Ported from Old Repo
#########################

### General

# Enable aliases to be sudo’ed
alias sudo='sudo '

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# Print each PATH entry on a separate line
alias path='echo -e ${PATH//:/\\n}'

### macos Specific

# Kill ARD Locked Screen
alias i_locked_myself_out="ps -ax | grep AppleVNCServer && echo && echo Contents/MacOS/LockScreen && echo sudo_kill_-9_PID"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Empty the Trash on all mounted volumes and the main HDD.
# Also, clear Apple’s System Logs to improve shell startup speed.
# Finally, clear download history from quarantine. https://mths.be/bum
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl; sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV* 'delete from LSQuarantineEvent'"

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"

# Hide/show all desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"

# PlistBuddy alias, because sometimes `defaults` just doesn’t cut it
alias plistbuddy="/usr/libexec/PlistBuddy"

### IP Stuff

# IP addresses

alias ip4_external="dig TXT +short -4 o-o.myaddr.l.google.com @ns1.google.com | awk -F'\"' '{ print \$2}'"
alias ip6_external="dig TXT +short -6 o-o.myaddr.l.google.com @ns1.google.com | awk -F'\"' '{ print \$2}'"

# List local ones
alias ip_local="ipconfig getifaddr en0"
alias ip_mine="ifconfig | grep \"inet \" | grep -Fv 127.0.0.1 | awk '{print \$2}'"

# List all ips
alias ip_all="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

#alias my_ip="ifconfig en0 | grep inet | grep -v inet6 | cut -d ' ' -f2"
alias my_open_ports="nmap -Pn \$(my_ip)" #"echo 'nmap -Pn \$(my_ip)'"

# Show active network interfaces
alias ifactive="ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'"
