#
# bashrc/bashrc
#
# imagine if this was all in one file x_x
#
# 4strid (Astrid Ivy) 
# 2019-01-21
# major revision 2023-12-27
#
######

# locate bashrc directory
BASHRC=$(dirname $(realpath ${BASH_SOURCE[0]}))

source $BASHRC/functions
source $BASHRC/exports
source $BASHRC/aliases
source $BASHRC/shortcuts
source $BASHRC/reflekt

# If not running interactively, don't do anything (else)
[[ $- != *i* ]] && return

source $BASHRC/shopts
source $BASHRC/danger

attempt is_tty && setfont Tamsyn8x16r

cdmod -p tryhard -g -v -P ls --color=auto
