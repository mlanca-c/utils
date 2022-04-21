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

function check_exists() {
	if [ $1 $2 ]; then
		if [ $1 == "-f" ]; then
			yes_or_no "$2 already exists. Do you to override existing Makefile?" && return 1
		fi
		return 0
	else
		echo "bash: $2: doesn't exist"; return 1
	fi
}

yes_or_no "Install Makefile" && (check_exists "-f" "Makefile" || (install "Makefile" && echo "Makfile: sure to replace every '...' with your preferences" && yes_or_no "initialize project folders?" && make folders))

yes_or_no "Install Hooks" && check_exists "-d" ".git" && mkdir -p .git/hooks/ && install "hooks/pre-commit" && mv pre-commit .git/hooks/

yes_or_no "Install asan" && ((check_exists "-d" "src" && mkdir -p src/asan/ && install "asan/asan.c" && mv asan.c src/asan/ ) || \
	install "asan/asan.c")

exit 0
