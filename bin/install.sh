[[ ! -f $HOME/.cutestrap ]] && cat > $HOME/.cutestrap <<EOF
#!/bin/bash
# cutestrap
# this suffices to load cute-ils

function import {
  local OPT=
  getopts "v" OPT
  shift \$((\$OPTIND - 1))

  # hardcoded for now
  for T in "." "./lib" "\$HOME/lib" "/usr/lib" "/lib" "\$HOME/src" ; do
    local SRC="\$T/\$1"
    if [[ -f "\$SRC" ]]; then
      local OLDERPWD=\$OLDPWD
      cd \`dirname "\$SRC"\`
      source \`basename "\$SRC"\`
      local STATUS=\$?
      cd "\$OLDPWD"
      export OLDPWD="\$OLDERPWD"
      return \$STATUS
    fi
  done

  [[ \$OPT == "v" ]] && echo "\$1 not found in libraries" >&2
}
EOF

BINPATH="$(dirname "$(realpath "$0")")"
INSTALLPATH="$HOME/src/bashrc"

if [[ $BINPATH == "$INSTALLPATH/bin" ]]; then {
  echo "Oh good I'm already in the right place."
} else {
  [[ ! -d $HOME/src ]] && mkdir "$HOME/src"
  [[ ! -d $HOME/src/bashrc ]] && mkdir "$HOME/src/bashrc"
  cd $BINPATH
  cd ..
  cp aliases exports shopts bashrc danger functions reflect shortcuts $INSTALLPATH
} fi

if [[ ! -f $HOME/.bashrc ]]; then
  cat >> $HOME/.bashrc <<EOF
# ~/.bashrc
#
# cutejs/bashrc

source \$HOME/.cutestrap
import bashrc/bashrc
EOF
elif grep -q "import bashrc/bashrc" $HOME/.bashrc; then
 echo "Looks like ~/.bashrc is already set up"
else
  cp $HOME/.bashrc $HOME/.bashrc.orig
  cat > $HOME/.bashrc.bootstrap <<EOF
# ~/.bashrc
#
# cutejs/bashrc

source \$HOME/.cutestrap
import bashrc/bashrc

EOF
  cat $HOME/.bashrc.bootstrap $HOME/.bashrc.orig > $HOME/.bashrc
  rm $HOME/.bashrc.bootstrap $HOME/.bashrc.orig
fi
