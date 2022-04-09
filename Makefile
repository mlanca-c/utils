# **************************************************************************** #
# Makefile
#
# User: mlanca-c
# Version: 2.1
# URL: https://github.com/mlanca-c/utils
#
# Description: This is my generic Makefile for projects.
# **************************************************************************** #

PROJECT	:= ...
VERSION	:= ...

USER	:= ...

# **************************************************************************** #
# Project Variables
# **************************************************************************** #

NAME1	:=	...			# Name of a single binary

NAMES	:= ${NAME1}		# List of all binary files.
						# If a name starts with ${TEST_PREFIX}, then instead of
						# going to ${BINS}, it will go to ${TEST_BINS}

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
VERBOSE := 1

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
PEDANTIC := false

# If set to true then all the *_ROOT variables will be set to './'.
# This is for small projects where it doesn't make sense to have everything
# separated.
SINGLE_DIR	:= false

# If set to true, then testing targets and folders will be set to use.
# Example:
# 	NAMES		:= test1 test2 bin1 bin2
# 	TESTING		:= true
# 	FIND_TEST	:= test
TESTING		:=
FIND_TEST	:=

# **************************************************************************** #
# Colors and Messages
# **************************************************************************** #

GREEN		:= \e[38;5;118m
YELLOW		:= \e[38;5;226m
RED			:= \e[38;5;9m
RESET		:= \e[0m

_SUCCESS	:= [${GREEN} ok ${RESET}]
_FAILURE	:= [${RED} ko ${RESET}]
_INFO		:= [${YELLOW} info ${RESET}]

# **************************************************************************** #
# Language Specs
# **************************************************************************** #

# Language name (Check specs below)
LANG	:= ...
LANG	:= $(shell echo '${LANG}' | tr '[:upper:]' '[:lower:]')

ifeq (${LANG}, c)
	EXTENSION	:= .c .h
endif
ifeq (${LANG}, $(filter, cpp c++))
	EXTENSION	:= .cpp .hpp
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
 TST_ROOT	:= tst/
 TBIN_ROOT	:= tbin/
else
 $(foreach var,\
	SRC_ROOT OBJ_ROOT INC_ROOT LIB_ROOT BIN_ROOT TST_ROOT TBIN_ROOT,\
    $(eval $(var) := ./)\
 )
endif
ifeq (${TESTING},false)
	undefine TEST_BINS TBIN_ROOT
endif

# **************************************************************************** #
# File Manipulation
# **************************************************************************** #

RM		:= rm -vf
CP		:= cp -r
MKDIR	:= mkdir -vp

# Definitions
T     := 1
comma := ,
empty :=
space := $(empty) $(empty)
tab   := $(empty)	$(empty)

# **************************************************************************** #
# Test Specs
# **************************************************************************** #

# Functions
# =========
# 1) eq: compares two strings
# 2) has-test-word: returns empty if filename doesn't start with TEST_PREFIX
#
# 3) is-test: returns empty if ${TESTING} is set to false or if FIND_TEST is
# 			empty. Else it returns a list of ${NAMES} that contain the string
# 			${FIND_TEST}.
#
# 4) not-test: returns ${NAMES} if ${TESTING} is set to false or if FIND_TEST
# 			is empty. Else it returns a list of ${NAMES} that do not contain the
# 			string ${FIND_TEST}.
#

define eq
$(strip $(if $(or $(strip $1),$(strip $2)),\
    $(if $(filter $(subst $(space),,$1),$(subst $(space),,$2)),T),T))
endef

has-test-word = $(foreach bin, $(1), $(shell echo $(bin) | grep ${FIND_TEST}))

define is-test
$(if $(call eq,${TESTING},true),\
	$(if ${FIND_TEST},\
		$(strip $(call has-test-word, $(1))),\
		${empty}\
		),\
	${empty}\
)
endef

define not-test
$(if $(call eq,${TESTING},true),\
	$(if $(FIND_TEST),\
		$(filter-out $(call has-test-word,$(1)), $(1)),\
		$(1)\
		),\
	$(1)\
)
endef

# **************************************************************************** #
# Folders
# **************************************************************************** #

# **************************************************************************** #
# Files
# **************************************************************************** #

# Directories List (root is SRC_ROOT)
DIRS	:= ./

# Test Directories List (root is TST_ROOT)
TSTDIRS	:= ./

# Files
SRCS	:=
OBJS	:=
INCS	:=
LIBS	:=

TEST_SRCS	:=
TEST_OBJS	:=
TEST_INCS	:=

# Binaries
BINS		:= $(call not-test, ${NAMES})
TEST_BINS	:= $(call is-test, ${NAMES})

# **************************************************************************** #
# Compiler and Flags
# **************************************************************************** #

# If set to true, the program will compile with a specific flag.
THREAD		:= false

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

# **************************************************************************** #
# Util Functions
# **************************************************************************** #

# Print a specifique variable
print-%: ; @echo $*=$($*)

# **************************************************************************** #
# **************************************************************************** #
