[[ ! -f $HOME/.cutestrap ]] && cat > $HOME/.cutestrap <<EOF
#!/bin/bash
# cutestrap
# this suffices to load cute-ils or cutejs' bashrc

function import {
  local OPT=
  getopts "v" OPT
  shift \$((\$OPTIND - 1))

  # hardcoded for now
  for T in "." "./lib" "\$HOME/lib" "/usr/lib" "/lib" "./src"; do
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

[[ ! -d $HOME/lib ]] && mkdir "$HOME/lib"

BINPATH="$(dirname "$(realpath "$0")")"
INSTALLPATH="$HOME/lib/bashrc"

ln -s $BINPATH/.. -T $INSTALLPATH

if [[ ! -f $HOME/.bashrc ]]; then
  cat >> $HOME/.bashrc <<EOF
# ~/.bashrc
#
# cutejs/bashrc

source \$HOME/.cutestrap
import bashrc/bashrc
EOF
elif grep -q "import bashrc/bashrc" $HOME/.bashrc; then
 echo "Looks like ~/.bashrc is already set up" 1>&2
else
  cat > $HOME/.bashrc.bootstrap <<EOF
# cutejs/bashrc

source \$HOME/.cutestrap
import bashrc/bashrc

EOF
  cp $HOME/.bashrc $HOME/.bashrc.orig
  cat $HOME/.bashrc.bootstrap $HOME/.bashrc.orig > $HOME/.bashrc
  rm $HOME/.bashrc.bootstrap $HOME/.bashrc.orig
fi
