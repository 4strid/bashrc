#
# bashrc/bashrc
#
# let's get organized
#
#
# cutejs (River Fesz-Nguyen)
# 2019-01-21
#

# disable cd mods while loading bashrc
# (fails on first run so ignore stderr)
cdmod -p -P 2>/dev/null

import -v functions
import -v exports
import -v aliases
import -v shortcuts
import -v reflect

# If not running interactively, don't do anything (else)
[[ $- != *i* ]] && return

import -v shopts
import -v danger

is_tty && setfont Tamsyn8x16r

cdmod -p tryhard -g -v -P ls --color=auto
