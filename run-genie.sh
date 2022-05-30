#!/bin/bash

set -e
set -o pipefail
set -x

Usage()
{
   echo ""
   echo "Usage: `basename $0` [options [parameters]]"
   echo "Options:"
   echo " -t | --test : Flag to enable test mode"
   echo " -i | --input : Path to the test file (optional)"
   echo " -o | --output : Path to the output file (optional)"
   echo " -n | --nlp_server : Set the NLP server (required)"
   echo " -h | --help : Print help"
   exit 0
}

nlp_server="local"
test_flag=false
SHORT=n:,t,i:,o:,h
LONG=nlp_server:,test,input:,output:,help
OPTS=$(getopt -o $SHORT --long $LONG --name "test.sh" -- "$@")
VALID_ARGS=$#
if [ "$VALID_ARGS" -eq 0 ]; then
  Usage
fi

eval set -- "$OPTS"

while true; 
do
  case "$1" in
	-n | --nlp_server)
		nlp_server="$2"
		shift 2
		;;
    -t | --test)
        test_flag=true
        shift 1
        ;;
    -i | --input)
        input="$2"
        shift 2
        ;;
    -o | --output)
        output="$2"
        shift 2
        ;;
    -h | --help) 
        Usage
        exit 0
        ;;
    --) # No more arguments
        shift;
        break
        ;;
    *) # Unknown option - will never get here because getopt catches up front
        echo "unknown error while processing options"
        Usage
        exit 1
        ;;
  esac
done

echo "nlp_server=$nlp_server, test=$test_flag, input=$input, output=$output, Leftovers: $@"

# . ./lib.sh
# parse_args "$0" "nlp_server" "$@"

if ! test -d ./.home ; then
	mkdir .home
	cat > .home/prefs.db <<EOF
{
  "developer-dir": "${PWD}/devices"
}
EOF
fi

run()
{
  env THINGENGINE_HOST_BASED_AUTHENTICATION=insecure
  if [ "$test_flag" = true ]
  then
    sleep 1s 
    i=1
    while IFS=$'\t' read -r pid utterance ttProgram ;
    do
    #   ttProgramNew='@com.yelp . restaurant ( ) filter geo == new Location(37.442156, -122.1634471, " Palo Alto, California " );'
    #   ttProgramNew='@com.yelp . restaurant ( ) filter geo == new Location( " Palo Alto, California " );'
	  ttProgramNew="${ttProgram//\"/\\\"}"
      response=$(curl -X POST -H "Content-Type: application/json" -d '{"type":"tt","code":"'"$ttProgramNew"'"}' http://localhost:3000/api/apps/create | python parser.py)
      printf "%03d-synthesized\n" $i >> $output
	  printf "U: ${utterance}\n"  >> $output
	  printf "UT: \$dialogue @org.thingpedia.dialogue.transaction.execute;\n"
      printf "UT: %s ${ttProgram}\n" "\t" >> $output
      printf "A: %s\n" "$response" >> $output
      printf "A: >> expecting = null\n" >> $output
      printf "\n====\n" >> $output
      i=$((i+1))
      # if [ "$i" = 3 ]
      # then
      #   break
      # fi
	#   break
    done < $input
    pid=`ps -aef | grep node | grep './genie-server/dist/main.js' | awk '{print $2}'`
    kill -9 ${pid}
  fi
}

export THINGENGINE_HOME=./.home
[ "${nlp_server}" = "local" ] && export THINGENGINE_NLP_URL=http://127.0.0.1:8400

exec node ./genie-server/dist/main.js | while read line ;
do
  if echo "$line" | grep "Ready"
  then
    run
  else
    echo "$line"
  fi
done