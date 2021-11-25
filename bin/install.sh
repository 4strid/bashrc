[[ ! -f $HOME/.cutestrap ]] && cat > $HOME/.cutestrap <<EOF
#!/bin/bash
# cutestrap
# this suffices to load cute-ils or 4strid's bashrc

function import {
  local OPT=
  getopts "v" OPT
  shift \$((\$OPTIND - 1))

  # hardcoded for now
  for T in "." "./lib" "\$HOME/src" "\$HOME/lib" "./src"; do
    local SRC="\$T/\$1"
    if [[ -f "\$SRC" ]]; then
      local ORIGPWD=\$PWD
      local OLDERPWD=\$OLDPWD
      cd \`dirname "\$SRC"\`
      source \`basename "\$SRC"\`
      local STATUS=\$?
      cd "\$ORIGPWD"
      export OLDPWD="\$OLDERPWD"
      return \$STATUS
    fi
  done

  [[ \$OPT == "v" ]] && echo "\$1 not found in libraries" >&2
}
EOF

BINPATH="$(dirname "$(realpath "$0")")"
INSTALLPATH="$HOME/lib/bashrc"

if [[ $BINPATH == "$INSTALLPATH/bin" ]]; then {
  echo "Oh good I'm already in the right place." 1>&2
} else {
  [[ ! -d $HOME/lib ]] && mkdir "$HOME/lib"
  [[ ! -d $HOME/lib/bashrc ]] && mkdir "$HOME/lib/bashrc"
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
  cat > $HOME/.bashrc.bootstrap <<EOF
# cutejs/bashrc

source \$HOME/.cutestrap
import bashrc/bashrc

EOF
  cp $HOME/.bashrc $HOME/.bashrc.orig
  cat $HOME/.bashrc.orig $HOME/.bashrc.bootstrap > $HOME/.bashrc
  rm $HOME/.bashrc.bootstrap $HOME/.bashrc.orig
fi
