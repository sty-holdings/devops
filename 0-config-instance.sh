#!/bin/bash
#
# This will install NATS, NATS CLI, and NSC. Additionally, it will create the operator account
#

sudo apt update
sudo apt-get install mlocate -y
sudo apt-get install unzip
sudo apt-get install zip

cd $HOME

FILE=.profile
ORIGINALFILE=.original.profile
if [ -f "$HOME/$ORIGINALFILE" ]; then
  cp "$HOME/$ORIGINALFILE" "$HOME/$FILE"
else
	cp "$HOME/$FILE" "$HOME/$ORIGINALFILE"
fi


cat >> "$HOME/$FILE" <<- EOF
	
	#
	# STYH startup profile

	echo
	echo "==> Updating locate DB =="
	sudo updatedb
	echo "==> Done"
	echo
	echo
	echo "==> Packages needing to be upgraded"
	sudo apt update
	sudo apt list --upgradable
	echo
	echo
	echo "==> Run the following command "
	echo "==> to get updated list. "
	echo "==> sudo apt list --upgradable "
	echo
	echo
EOF


FILE=.bash_aliases
cat > "$HOME/$FILE" <<- EOF
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

echo
echo
echo "==> You must run: . ~/.bashrc"
echo
echo