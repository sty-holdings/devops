sudo apt-get install mlocate -y


FILE=.profile
CONTAINS_STRING="# STYH startup profile"
if ! grep -q CONTAINS_STRING "$FILE"; then
  cp .profile .saved.profile
	cat >> .profile <<- EOF
	
	#
	# STYH startup profile
	sh styh.profile
	EOF
fi

FILE=styh.profile
if ! test -f "$FILE"; then
  # if running bash
	if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bash_aliases" ]; then
        . "$HOME/.bash_aliases"
    fi
	fi

	cat > styh.profile <<- EOF
	echo
	echo "========================="
	echo "==  Updating locate DB =="
	sudo updatedb
	echo Done
	echo "========================="
	echo
	echo "========================="
	echo "Packages needing to be upgraded"
	sudo apt list --upgradable
	echo "=                       ="
	echo " run the following command "
	echo " to get updated list. "
	echo " > sudo apt list --upgradable "
	echo "========================="
EOF
fi

FILE=.bash_aliases
if test -f "$FILE"; then
cat > .bash_aliases <<- EOF
	#
	# GOLANG
	#
	alias gopath='cd $GOPATH'
	alias gobin='cd $GOBIN'
	alias gobuild='cd $GOBUILD'
	alias gosrc='cd $GOSRC'
	alias goconfig='cd $GOCONFIG'
	alias gopkg='cd $GOPKG'
	alias goutils='cd $GOPATH/src/utils'

	#
	# BASH Shell
	#
	alias home='cd ~'
	alias reset='source ~/.bashrc'
	alias lsl='ls -la --color=auto'
	alias back='cd ..'

	#
	# STYH Commands
	#
	alias styh='cd ~/styh/servers'
	alias styhbin='cd ~/styh/servers/bin'
	alias styhscripts='cd ~/styh/servers/scripts'
	#
	alias web='cd /var/www'
	alias styhexternal='cd /var/www/styh_external_site.com'
	alias styhwiki='cd /var/www/styh_wiki_site.com'
	alias savupbeta='cd /var/www/savup_beta.com'
	alias savupmy='cd /var/www/savup_my.com'
	alias savupwaiting='cd /var/www/savup_waiting_list.com'
	EOF
fi

. ~/.profile