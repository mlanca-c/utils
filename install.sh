# **************************************************************************** #
# install.sh
#
# User: mlanca-c
# Version: 2.1
# URL: https://github.com/mlanca-c/utils
# **************************************************************************** #

#!/bin/sh
#
# The above indicates that the Bourne shell `sh` command shell will be used to run the script.

function yes_or_no() {
	while true
	do
		read -r -p "$1 [Y/n]: " yn

		case $yn in
			[Yy]*) return 0  ;;  
			"") return 0  ;;  
			[Nn]*) return  1 ;;
		esac
	done
}

function install() {
		if curl https://raw.githubusercontent.com/mlanca-c/utils/master/$1 > $1
		then
			echo "$1: installed"
		else
			echo "bash: curl: $1: failed to install"
		fi
}

yes_or_no "Install Makefile" && install "Makefile" && echo "Make sure to replace every '...' in Makefile with your preferences"

# Intall Makefile
# Say to add things to ...
# Ask If I want to create folders? If I say no then tell me to put true in Makefile

# Ask if I want the ASAN folder and if src exists put it there otherwise ./

# Ask to install hooks? And say what they are about.
# Exit status 
