# **************************************************************************** #
# Makefile
#
# User: mlanca-c
# Version: 2.1
# URL: https://github.com/mlanca-c/utils
#
# Description: This is a generic Makefile.
# **************************************************************************** #

PROJECT	:= ...
VERSION	:= ...

USER	:= ...

# **************************************************************************** #
# Project Variables
# **************************************************************************** #

NAME1	:=	...

NAMES	:= ${NAME1}

# **************************************************************************** #
# Specifications and Initial Configs
# **************************************************************************** #

# Operative System
OS	:= $(shell uname)

# Verbose levels
# 0: Make will be totaly silenced
# 1: Make will print echos and printf
# 2: Make will not be silenced but target commands will not be printed
# 3: Make will print each command
# 4: Make will print all debug info
#
# @author fletcher97
VERBOSE := 2

ifeq (${VERBOSE},0)
	MAKEFLAGS += --silent
	BLOCK := 1>/dev/null
else ifeq (${VERBOSE},1)
	MAKEFLAGS += --silent
else ifeq (${VERBOSE},2)
	AT := @
else ifeq (${VERBOSE},4)
	MAKEFLAGS += --debug=v
endif

# Pedantic allows for extra warning flags to be used while compiling. If set to
# true these flags are applied. If set to anything else the flags will not be
# used. By default it's turned on.
#
# @author fletcher97
PEDANTIC	:= false

# If set to true then all the *_ROOT variables will be set to './'.
# This is for small projects where it doesn't make sense to have everything
# separated.
SINGLE_DIR	:= false

# Test flag
TESTING		:= false

# **************************************************************************** #
# Colors and Messages
# **************************************************************************** #

GREEN		:= \e[38;5;118m
BLUE		:= \e[38;5;20m
YELLOW		:= \e[38;5;226m
RED			:= \e[38;5;9m
DRED		:= \e[38;5;88m
RESET		:= \e[0m

_OBJS	:= [${DRED} obj ${RESET}]:
_BINS	:= [${BLUE} bin ${RESET}]:

_SUCCESS	:= [${GREEN} ok ${RESET}]:
_FAILURE	:= [${RED} ko ${RESET}]:
_INFO		:= [${YELLOW} info ${RESET}]:

# **************************************************************************** #
# Language Specs
# **************************************************************************** #

LANG	:= ...
LANG	:= $(shell echo '${LANG}' | tr '[:upper:]' '[:lower:]')

# Add more extensions here.
ifeq (${LANG},c)
	EXTENSION	:= .c
endif
ifeq (${LANG},$(filter, cpp c++))
	EXTENSION	:= .cpp
endif

# **************************************************************************** #
# Root Folders
# **************************************************************************** #

ifeq (${SINGLE_DIR},false)
 SRC_ROOT	:= src/
 OBJ_ROOT	:= obj/
 INC_ROOT	:= inc/
 LIB_ROOT	:= lib/
 BIN_ROOT	:= bin/
else
 $(foreach var,\
	SRC_ROOT OBJ_ROOT INC_ROOT LIB_ROOT BIN_ROOT,\
    $(eval $(var) := ./)\
 )
endif

# **************************************************************************** #
# Libraries
# **************************************************************************** #

# libft
LIBFT_TARGET	:= false
LIBFT_ROOT	:= ${LIB_ROOT}libft/
LIBFT_INC	:= ${LIBFT_ROOT}inc/
LIBFT		:= ${LIBFT_ROOT}bin/libft.a

ifeq (${LIBFT_TARGET},false)
	undefine LIBFT
	undefine LIBFT_ROOT
	undefine LIBFT_INC
endif

# All libs
INC_DIRS	+= ${LIBFT_INC}
LIBS		:= ${LIBFT}

# **************************************************************************** #
# File Manipulation
# **************************************************************************** #

RM		:= rm -vf
PRINT	:= printf
CP		:= cp -r
MKDIR	:= mkdir -vp
NORM	:= norminette
ifeq (${OS},Linux)
SED		:= sed -i.tmp --expression
else ifeq (${OS},Darwin)
SED		:= sed -i.tmp
endif

# Definitions
T		:= 1
comma	:= ,
empty	:=
space	:= $(empty) $(empty)
tab		:= $(empty)	$(empty)

# **************************************************************************** #
# Functions
# **************************************************************************** #

define eq
$(strip $(if $(or $(strip $1),$(strip $2)),\
    $(if $(filter $(subst $(space),,$1),$(subst $(space),,$2)),T),T))
endef

# **************************************************************************** #
# Test Specs
# **************************************************************************** #

# Test Specifications
# ===================
# 2) has-test-word: returns empty if filename doesn't start with TEST_PREFIX
#
# 3) is-test: returns empty if ${TESTING} is set to false or if FIND_TEST is
# 			empty. Else it returns a list of ${NAMES} that contain the string
# 			${FIND_TEST}.
#
# 4) not-test: returns ${NAMES} if ${TESTING} is set to false or if FIND_TEST
# 			is empty. Else it returns a list of ${NAMES} that do not contain the
# 			string ${FIND_TEST}.

has-test-word = $(foreach bin,$(1),$(shell echo $(bin) | grep ${FIND_TEST}))

define is-test
$(if $(call eq,${TESTING},true),\
	$(if ${FIND_TEST},\
		$(strip $(call has-test-word,$(1))),\
		${empty}\
		),\
	${empty}\
)
endef

define not-test
$(if $(call eq,${TESTING},true),\
	$(if $(FIND_TEST),\
		$(filter-out $(call has-test-word,$(1)),$(1)),\
		$(1)\
		),\
	$(1)\
)
endef

# **************************************************************************** #
# Folders
# **************************************************************************** #

# Directories List (root is SRC_ROOT)
DIRS	:= ./

SRC_DIRS_LIST	:= $(addprefix ${SRC_ROOT},${DIRS})
SRC_DIRS_LIST	:= $(foreach dir,${SRC_DIRS_LIST},\
				   $(subst :,:${SRC_ROOT},${dir}))

SRC_DIRS	:= $(subst :,${space},${SRC_DIRS_LIST})
OBJ_DIRS	:= $(subst ${SRC_ROOT},${OBJ_ROOT},${SRC_DIRS})
INC_DIRS	+= ${INC_ROOT}

# **************************************************************************** #
# Files
# **************************************************************************** #

SRCS	:= $(foreach dir,${SRC_DIRS},$(wildcard ${dir}*${EXTENSION}))
OBJS	:= $(subst ${SRC_ROOT},${OBJ_ROOT},${SRCS:.c=.o})
INCS	:= $(addprefix -I,${INC_DIRS})
BINS	:= $(addprefix ${BIN_ROOT},${NAMES})

# **************************************************************************** #
# Compiler and Flags
# **************************************************************************** #

THREAD	:= false

ifeq (${LANG},$(filter ${LANG},cpp c++ c))
	CFLAGS	:= -Wall -Wextra -Werror
	FLAGS 	:= ${CFLAGS}
	ifeq (${LANG},c)
		CC	:= gcc
	endif
	ifeq (${LANG},$(filter ${LANG},cpp c++))
		CC		:= c++
		VFLAGS	:= -std=c++98
		FLAGS	+= ${VFLAGS}
	endif
	ifeq (${CC},gcc)
		DFLAGS	:= -g
		ASAN 	:= -fsanitize=address -fsanitize-recover=address
		ASAN 	+= -fno-omit-frame-pointer -fno-common
		ASAN 	+= -fsanitize=pointer-subtract -fsanitize=pointer-compare
		ASAN 	+= -fsanitize=undefined
		ifeq (${OS},Linux)
			ASAN 	+= -fsanitize=leak
		endif
		TSAN 	:= -fsanitize=thread
		MSAN 	:= -fsanitize=memory -fsanitize-memory-track-origins
	endif
	ifeq (${THREAD},true)
		PTFLAG	:= -pthread
		FLAGS	+= ${PTFLAG}
	endif
endif

# Pedantic flags
ifneq (${LANG},$(filter ${LANG},cpp c++ c))
	undefine PEDANTIC
endif
ifeq (${PEDANTIC},true)
	CFLAGS	+= -Wpedantic -Werror=pedantic -pedantic-errors -Wcast-align
	CFLAGS	+= -Wcast-qual -Wdisabled-optimization -Wformat=2 -Wuninitialized
	CFLAGS	+= -Winit-self -Wmissing-include-dirs -Wredundant-decls -Wshadow
	CFLAGS	+= -Wstrict-overflow=5 -Wundef -fdiagnostics-show-option
	CFLAGS	+= -fstack-protector-all -fstack-clash-protection
	ifeq (${CC},gcc)
		CFLAGS	+= -Wformat-signedness -Wformat-truncation=2 -Wformat-overflow=2
		CFLAGS	+= -Wlogical-op -Wstringop-overflow=4
	endif
	ifeq (${LANG},LANG_CPP)
		CFLAGS	+= -Wctor-dtor-privacy -Wold-style-cast -Woverloaded-virtual
		CFLAGS	+= -Wsign-promo
		ifeq (${CC},gcc)
			CFLAGS	+= -Wstrict-null-sentinel -Wnoexcept
		endif
	endif
endif

# **************************************************************************** #
# Project Targets
# **************************************************************************** #

all: ${BINS}

${BIN_ROOT}${NAME1}: $(call get_files,$$(@F),$${OBJS_LIST})
	${AT}${MKDIR} ${@D} ${BLOCK}
	${AT}${CC} ${CFLAGS} ${INCS} $(call get_files,${@F},${OBJS_LIST}) ${LIBS}\
		-o $@ ${BLOCK}

# **************************************************************************** #
# Clean Targets
# **************************************************************************** #

clean:

fclean:

re:

# **************************************************************************** #
# Debug Targets
# **************************************************************************** #

debug:

debug_re:

debug_asan:

# **************************************************************************** #
# Utils Targets
# **************************************************************************** #

# .PHONY: .init
# .init: clear
# 	${AT}mkdir -p ${SRC_ROOT} ${BLOCK}
# 	${AT}mkdir -p ${INC_ROOT} ${BLOCK}
# 	${AT}mkdir -p ${OBJ_ROOT} ${BLOCK}
# 	${AT}mkdir -p ${LIB_ROOT} ${BLOCK}
# 	${AT}git clone git@github.com:${USER1}/Generic-README.git ${BLOCK}
# 	${AT}mv Generic-README/README.md ./ ${BLOCK}
# 	${AT}rm -rf Generic-README ${BLOCK}
# 	${AT}${SED} 's/NAME/${PROJECT}/g' README.md ${BLOCK}
# 	${AT}git init ${BLOCK}
# 	${AT}echo "*.o\n*.d\n.vscode\na.out\n.DS_Store" > .gitignore ${BLOCK}
# 	${AT}git add README.md ${BLOCK}
# 	${AT}git add .gitignore ${BLOCK}
# 	${AT}git add Makefile ${BLOCK}
# 	${AT}git commit -m "first commit - via Makefile (automatic)" ${BLOCK}
# 	${AT}git branch -M main ${BLOCK}
# 	${AT}git remote add origin git@github.com:${USER1}/${PROJECT}.git ${BLOCK}
# 	${AT}git status ${BLOCK}
# 	${AT}printf "Poject folders created ................ ${_SUCCESS}\n" ${BLOCK}
# 	${AT}printf "Cloned Generic-README to project ...... ${_SUCCESS}\n" ${BLOCK}
# 	${AT}printf "README.md created ..................... ${_SUCCESS}\n" ${BLOCK}
# 	${AT}printf "Git Repository initialized ............ ${_SUCCESS}\n" ${BLOCK}
# 	${AT}printf "README.md added to repository ......... ${_SUCCESS}\n" ${BLOCK}
# 	${AT}printf ".gitignore added to repository......... ${_SUCCESS}\n" ${BLOCK}
# 	${AT}printf "Makefile added to repository .......... ${_SUCCESS}\n" ${BLOCK}
# 	${AT}printf "Setup ready ........................... ${_SUCCESS}\n" ${BLOCK}
# 	${AT}printf "[${YELLOW} push ${RESET}]: git push -u origin main\n" ${BLOCK}

.init:
	${AT}${PRINT} "${_INFO} creating structure\n" ${BLOCK}
	${AT}${MKDIR} ${SRC_ROOT} ${BLOCK}
	${AT}${MKDIR} ${INC_ROOT} ${BLOCK}
	${AT}${MKDIR} ${LIB_ROOT} ${BLOCK}
	${AT}${PRINT} "${_INFO} initializing git\n" ${BLOCK}
	${AT}git init${BLOCK}
	${AT}echo "*.o\n*.d\n.vscode\na.out\n.DS_Store\nbin/\n*.ignore"\
		> .gitignore ${BLOCK}
	${AT}git clone git@github.com:${USER1}/Generic-README.git ${BLOCK}
	${AT}mv Generic-README/README.md ./ ${BLOCK}
	${AT}rm -rf Generic-README ${BLOCK}
	${AT}${SED} 's/NAME/${PROJECT}/g' README.md ${BLOCK}
	${AT}git add .gitignore ${BLOCK}
	${AT}git add Makefile ${BLOCK}
	${AT}git commit -m "initial commit" ${BLOCK}
	${AT}git branch -M main ${BLOCK}
	${AT}git remote add origin git@github.com:${USER1}/${PROJECT}.git ${BLOCK}
	${AT}git status ${BLOCK}

ifeq (${LANG},c)
norm:
	${NORM}
endif

# Print a specific variable
print-%: ; @echo $*=$($*)

# **************************************************************************** #
# Functions
# **************************************************************************** #

# **************************************************************************** #
# Target Template
# **************************************************************************** #

define make_bin
$(1): $(2)
endef

define make_obj
$(1): $(2) $(3)
	$${AT}$${PRINT} "$${_OBJECTS} $$@\n" $${BLOCK}
	$${AT}$${CC} $${CFLAGS} $${INCS} -c $$< -o $$@ $${BLOCK}
endef 

# **************************************************************************** #
# Target Generator
# **************************************************************************** #

ifneq (${BIN_ROOT},./)
$(foreach bin,${BINS},$(eval\
$(call make_bin,$(notdir ${bin}),${bin})))
endif

$(foreach src,${SRCS},$(eval\
$(call make_obj,$(subst ${SRC_ROOT},${OBJ_ROOT},${src:.c=.o}),${src})))

# **************************************************************************** #
# **************************************************************************** #
