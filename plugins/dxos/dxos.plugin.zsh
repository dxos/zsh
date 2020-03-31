#
# DxOS utils.
#

dxos () {
  case "$1" in
    "info")
      ;;

    "help" | *)
      echo "dx [info]"
    ;;
  esac
}

alias dx=dxos
