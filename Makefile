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
OBJ_EXTENSION	:= .o
endif
ifeq (${LANG},$(filter, cpp c++))
EXTENSION	:= .cpp
OBJ_EXTENSION	:= .o
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
LIBFT_ROOT		:= ${LIB_ROOT}libft/
LIBFT_INC		:= ${LIBFT_ROOT}inc/
LIBFT			:= ${LIBFT_ROOT}bin/libft.a

ifeq (${LIBFT_TARGET},false)
	undefine LIBFT
	undefine LIBFT_ROOT
	undefine LIBFT_INC
endif

# MiniLibX
MLX_TARGET	:= true
ifeq (${OS},Linux)
MLX_ROOT	:= ${LIB_ROOT}minilibx-linux/
MLXFLAGS	:= -lbsd -L${MLX_ROOT} -lmlx -lXext -lX11 -lm
MLX			:= minilibx-linux
else ifeq (${OS},Darwin)
MLX_ROOT	:= ${LIB_ROOT}minilibx_mms/
MLXFLAGS	:= -L${MLX_ROOT} -lmlx 
MLX			:= minilibx_mms
endif
MLX_INC		:= ${MLX_ROOT}

ifeq (${MLX_TARGET},false)
	undefine MLX 
	undefine MLX_ROOT
	undefine MLX_INC
	undefine MLX_FLAG
endif

# All libs
INC_DIRS	+= ${LIBFT_INC} ${MLX_INC}
LIBS		:= ${LIBFT}

# **************************************************************************** #
# File Manipulation
# **************************************************************************** #

RM		:= rm -f
PRINT	:= printf
CP		:= cp -r
MKDIR	:= mkdir -p
NORM	:= norminette
FIND	:= find
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

# If MLX_TARGET = true, add this line to target: ${MAKE} -C ${MLX_ROOT}
${BIN_ROOT}${NAME1}: ${LIBFT} ${OBJS}
	${AT}${MKDIR} ${@D} ${BLOCK}
	${AT}${CC} ${FLAGS} ${INCS} ${OBJS} ${MLX_FLAG} ${LIBS} -o $@ ${BLOCK}
	${AT}${PRINT} "${_BINS} $@\n"${BLOCK}

${LIBFT}:
	${AT}${MAKE} -C ${LIBFT_ROOT} VERBOSE=${VERBOSE} ${BLOCK}

# **************************************************************************** #
# Clean Targets
# **************************************************************************** #

clean:
	${AT}${MAKE} $@ -C ${LIBFT_ROOT} ${BLOCK}
	${AT}${PRINT} "${_INFO} ${PROJECT}: object files removed\n" ${BLOCK}
	${AT}${MKDIR} ${OBJ_ROOT} ${BLOCK}
	${AT}${FIND} ${OBJ_ROOT} -type f -name "*${OBJ_EXTENSION}" -delete ${BLOCK}

fclean: clean
	${AT}${MAKE} $@ -C ${LIBFT_ROOT} ${BLOCK}
	${AT}${PRINT} "${_INFO} ${PROJECT}: binaries files removed\n" ${BLOCK}
	${AT}mkdir -p ${BIN_ROOT} ${BLOCK}
	${AT}${FIND} ${BIN_ROOT} -type f\
		$(addprefix -name ,${NAMES}) -delete ${BLOCK}

re: fclean all

# **************************************************************************** #
# Debug Targets
# **************************************************************************** #

debug: CFLAGS += ${DFLAGS}
debug: ${MAKE} $$@ -C ${LIBFT_ROOT}
debug: all

debug_re: fclean debug

debug_asan: CFLAGS += ${DFLAGS} ${ASAN}
debug_asan: ${MAKE} $$@ -C ${LIBFT_ROOT}
debug_asan: all

debug_asan_re: fclean debug_asan

# **************************************************************************** #
# Utils Targets
# **************************************************************************** #

.init:
	${AT}${MKDIR} ${SRC_ROOT} ${BLOCK}
	${AT}${MKDIR} ${INC_ROOT} ${BLOCK}
	${AT}${MKDIR} ${LIB_ROOT} ${BLOCK}
	${AT}${PRINT} "${_INFO} ${PROJECT}: structure created\n" ${BLOCK}
	${AT}git init${BLOCK}
	${AT}${PRINT} "${_INFO} git: repository initialed\n" ${BLOCK}
	${AT}echo "*.o\n*.d\n.vscode\na.out\n.DS_Store\nbin/\n*.ignore"\
		> .gitignore ${BLOCK}
	${AT}${PRINT} "${_INFO} git: .gitignore: file created\n" ${BLOCK}
	${AT}git clone git@github.com:${USER1}/Generic-README.git ${BLOCK}
	${AT}mv Generic-README/README.md ./ ${BLOCK}
	${AT}rm -rf Generic-README ${BLOCK}
	${AT}${SED} 's/NAME/${PROJECT}/g' README.md ${BLOCK}
	${AT}${PRINT} "${_INFO} git: README.md: file created\n" ${BLOCK}
	${AT}git add README.md ${BLOCK}
	${AT}git add .gitignore ${BLOCK}
	${AT}git add Makefile ${BLOCK}
	${AT}git commit -m "first commit - via Makefile (automatic)" ${BLOCK}
	${AT}${PRINT} "${_INFO} git: commit: \"initial commit\"\n" ${BLOCK}
	${AT}git branch -M main ${BLOCK}
	${AT}git remote add origin git@github.com:${USER1}/${PROJECT}.git ${BLOCK}
	${AT}${PRINT} "${_INFO} ${PROJECT}: project initialized\n" ${BLOCK}

ifeq (${LANG},c)
norm:
	${NORM}
endif

print-%: ; @echo $*=$($*)

# **************************************************************************** #
# .PHONY
# **************************************************************************** #

# Phony clean targets
.PHONY: clean fclean clean_all

# Phony debug targets
.PHONY: debug debug_re debug_asan debug_asan_re

# Phony execution targets
.PHONY: re all

# **************************************************************************** #
# Functions
# **************************************************************************** #

define eq
$(strip $(if $(or $(strip $1),$(strip $2)),\
    $(if $(filter $(subst $(space),,$1),$(subst $(space),,$2)),T),T))
endef

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

define norm
$(if ${LANG},c,\
	$(if $(shell ${NORM} | grep Error),, \
	${PRINT} "${_KO} norminette failing in some files\n")\
)
endef

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
