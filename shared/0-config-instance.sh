#!/bin/bash
#
# This will install generally needed packages and config login
#
BASHRC=.bashrc
BASH_ALIASES=.bash_aliases
BASH_EXPORTS=.bash_exports
#
PROFILE=.profile
#
VIMRC=/etc/vim/vimrc
VIMRC_OG=/etc/vim/original.vimrc
#
ORIGINAL=.original
UPGRADE_DONE=.apt_upgrade.dont_delete

sudo apt-get update

if ! [ -f "${HOME}/$UPGRADE_DONE" ]; then
	sudo apt-get install acl -y
	sudo apt-get install mlocate -y
	sudo apt-get install unzip -y
	sudo apt-get install zip -y
	sudo apt-get upgrade tcpdump -y
	touch "${HOME}"/"${UPGRADE_DONE}"
fi

echo
echo "==> Checking if $BASHRC will load $BASH_EXPORTS"
if grep -q "$HOME/$BASH_EXPORTS" "$HOME/$BASHRC"; then
	echo "==> $BASHRC is already updated to load $BASH_EXPORTS"
else
	echo "==> Adding exports loading to $BASHRC"
	cp "${HOME}/${BASHRC}" "${HOME}/${ORIGINAL}${BASHRC}"
	cat >> "${HOME}/${BASHRC}" <<- EOF
		if [ -f "${HOME}/${BASH_EXPORTS}" ]; then
    	. "${HOME}/${BASH_EXPORTS}"
		fi
	EOF
fi

echo
echo "==> Updating $PROFILE"
if [ -f "${HOME}/${ORIGINAL}${PROFILE}" ]; then
  cp "${HOME}/${ORIGINAL}${PROFILE}" "${HOME}/${PROFILE}"
else
	cp "${HOME}/${PROFILE}" "${HOME}/${ORIGINAL}${PROFILE}"
fi


cat >> "${HOME}/${PROFILE}" <<- EOF
	
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

echo
echo "==> Creating the $BASH_ALIASES"
cat > "${HOME}/${BASH_ALIASES}" <<- EOF
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
	alias styhexternal='cd /var/www/styh_external_site.com'
	alias styhwiki='cd /var/www/styh_wiki_site.com'
	alias savupbeta='cd /var/www/savup_beta.com'
	alias savupmy='cd /var/www/savup_my.com'
	alias savupwaiting='cd /var/www/savup_waiting_list.com'

	#
	# Admin
	#
	alias mountpoints='sudo lsblk'
	alias web='cd /var/www'

	#
	# NATS Commands
	#
	alias natshome='cd /mnt/disks/nats_home'
	
EOF

echo
echo "==> Creating the $BASH_EXPORTS"
cat > "${HOME}/${BASH_EXPORTS}" <<- EOF

	# To add exports, make sure to update the 0-config-instance.sh file in the devops GITHUB repository

EOF

echo
echo "==> Updating $VIMRC"
if [ -f "${VIMRC_OG}" ]; then
  sudo cp "${VIMRC_OG}" "$VIMRC"
else
	sudo cp "${VIMRC}" "${VIMRC_OG}"
	sudo chmod 666 "${VIMRC}"
	echo
	echo "==> Updating the ${VIMRC}"
	sudo cat >> "${VIMRC}" <<- EOF

	"
	" STYH global configuration
	filetype on
	filetype plugin on
	filetype indent on
	syntax on
	set nocompatible
	set number
	set cursorline
	set cursorcolumn
	set shiftwidth=2
	set tabstop=2
	set showmode
	set showmatch
	set hlsearch
	EOF
fi
sudo chmod 644 "${VIMRC}"
