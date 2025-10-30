#!/bin/sh

set -e

installHelp() {
  cat <<EOF
Description: nx installer.

Usage: ${0##*/} [TARGET_DIR]
EOF
}

if [ "$1" = help ] || [ "$1" = --help ] || [ "$1" = -h ]; then
  installHelp
  exit 0
fi

exe_name=nx
bin_name=${exe_name}.sh
install_dir=${1:-$HOME/.local/bin}
target="$install_dir/$exe_name"
entry=$(CDPATH="" cd -- "$(dirname "$0")" && pwd)/$bin_name

mkdir -p "$install_dir"

cat <<EOF >"$target"
#!/bin/sh

set -e

$entry "\$@"
EOF

chmod 744 "$target"

case :$PATH: in
*":$install_dir:"*)
  # The install dir is already in the shell path, nothing to do.
  ;;
*)
  cat <<EOF
"$install_dir" is not in your shell path.
Please add it with "PATH=$install_dir:\$PATH"
or move "$target" to an appropriate place.
EOF
  ;;
esac
