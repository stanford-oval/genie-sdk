parse_args() {
  local dollarzero argnames arg argvalue ok
  dollarzero=$1
  shift
  argnames=$1
  shift
  n=0

  while test $# -gt 0 ; do
    arg=$1
    shift
    n=$((n+1))
    if test "$arg" = "--" ; then
      break
    fi
    ok=0
    if test "$arg" = "--help" || test "$arg" = "-h" ; then
      echo -n "Usage: $dollarzero" 1>&2
      for argname in $argnames ; do
        echo -n " --$argname <$argname>" 1>&2
      done
      echo
      exit 0
    fi
    for argname in $argnames ; do
      if test "$arg" = "--$argname" ; then
        argvalue=$1
        ok=1
        n=$((n+1))
        shift
        declare -g "$argname"="$argvalue"
        break
      fi
    done
    if test "$ok" = "0" ; then
      echo "Invalid command-line argument ${arg}" 1>&2
      exit 1
    fi
  done
  for argname in $argnames ; do
    if test -z "${!argname}" ; then
      echo "Missing required command-line argument --${argname}" 1>&2
      exit 1
    fi
  done
}

