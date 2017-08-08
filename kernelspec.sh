#!/bin/bash -eu

function check_user_mode() {
    local jupyter=$(type -p jupyter 2>/dev/null)

    if [[ "$jupyter" == '' ]]; then
        return 1
    elif [[ "$jupyter" =~ ^$HOME ]]; then
        return 0
    else
        return 1
    fi
}

function get_ocaml_version() {
    if type -p opam >/dev/null 2>/dev/null; then
        opam config var switch
    else
        ocaml -vnum
    fi
}

function create() {
    local bindir=$1

    cat <<EOF
{
  "display_name": "OCaml ${OCAML_VERSION}",
  "language": "OCaml",
  "argv": [
    "${bindir}/ocaml-jupyter-kernel",
    "--init",
    "${HOME}/.ocamlinit",
    "--merlin",
    "${bindir}/ocamlmerlin",
    "--connection-file",
    "{connection_file}"
  ]
}
EOF
}

function install() {
    local install_kernel=$1
    local datadir=$2
    local flags=''

    if check_user_mode; then
        flags+=' --user'
    fi

    if [[ "$install_kernel" == 'true' ]] && type jupyter >/dev/null 2>&1; then
        jupyter kernelspec install --name "$KERNEL_NAME" $flags "$datadir"
        jupyter nbextension install $flags ocaml-theme
        jupyter nbextension enable $flags ocaml-theme/ocaml-theme
    fi
}

function uninstall() {
    if type jupyter >/dev/null 2>&1; then
        jupyter kernelspec remove "$KERNEL_NAME" -f
    fi
}

OCAML_VERSION=$(get_ocaml_version | sed 's@[^0-9A-Za-z_\.+-]@_@g')
KERNEL_NAME="ocaml-jupyter-${OCAML_VERSION}"

case $1 in
    create )
        create $2
    ;;
    install )
        install $2 $3
    ;;
    uninstall )
		uninstall
	;;
esac