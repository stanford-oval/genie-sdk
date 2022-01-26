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

venv_activate() {
	venv=$1
	if [[ -n "${VIRTUAL_ENV}" ]] ; then
		deactivate
	elif [[ -n "${CONDA_DEFAULT_ENV}" ]] ; then 
		CONDA_VERSION=$(cut -d ' ' -f 2 <<< "$(conda -V)")
		VERSION_NUM=$(cut -d '.' -f 1,2 <<< "$CONDA_VERSION")
		if [[ "`echo "${VERSION_NUM} < 4.6" | bc`" -eq 1 ]]; then
			conda init bash
			source deactivate
		else 
			conda init bash
			conda deactivate 
		fi
	fi

	python3 -m pip install --user virtualenv
	python3 -m virtualenv .virtualenv/$venv --python=$(which python3.9)
	source .virtualenv/$venv/bin/activate
}