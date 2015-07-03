#!/usr/bin/bash
DO_LOGIN=0
#if [[ $1 == '-' || $1 == '-l' || $1 == '--login' ]]; then
#	DO_LOGIN=1
#	shift 1
#fi

OPTIND=1
COMMAND=""
while getopts "c:pml-:" opt; do
	case "$opt" in
		-)
			case "${OPTARG}" in
				login)
					DO_LOGIN=1
					break
					;;
				help)
					show_help
					exit 0
					;;
				session-command)
					COMMAND=$OPTARG
					;;
				version)
					echo "This is just a script to mimic real su"
					;;
				*)
					echo "unknown arg ${OPTARG}"
			esac
			;;
			# just a dash
		l)
			DO_LOGIN=1
			;;
		c)
			COMMAND=$OPTARG
			;;
		p|m)
			#preserve env
			;;
	esac
done
shift "$((OPTIND-1))"

#work around
if [ "$1" == '-' ]; then
	DO_LOGIN=1
	shift
fi

if [ -n "$1" ]; then
	USER="$1"
else
	#use elevated instead of switch user
	USER="root"
fi
shift 1


#set runuser $1

CURDIR=$(cygpath -w $(pwd))
if [ $DO_LOGIN == 1 ]; then
	#TTYCMD="/bin/bash --login $@"
	TTYCMD="- $COMMAND"
else
	TTYCMD="$COMMAND"
fi

#print the commands
set -x
if [ $USER != 'root' ]; then
	#echo "runas /savecred /user:$runuser \"mintty -c '$@' \""
	#runas /savecred /user:$runuser "mintty -c '$@' "
	#echo "cygstart --action=runas" $(cygpath -w /usr/bin/mintty.exe) /savecred /user:$USER"
	#cygstart -v --action=runas $(cygpath -w /usr/bin/mintty.exe) 
	#cygstart -v --action=runas cmd.exe /c '"C:\\windows\\system32\\runas.exe"' "/savecred /user:$USER $(cygpath -w /usr/bin/mintty.exe)"
	
	#cygstart -v cmd.exe /k "\"\"%WINDIR%\\system32\\runas.exe\" /savecred /user:$USER \"$(cygpath -w /usr/bin/mintty.exe) -d $CURDIR\"\""

	#cygstart -v cmd.exe /k '"%WINDIR%\\system32\\runas.exe"' "/savecred /profile /env /user:$USER \:$(cygpath -w /usr/bin/mintty.exe) -d $(cygpath -w .)\""
	#cygstart -v cmd.exe /k "\"C:\\windows\\system32\\runas.exe\"" "/savecred /profile /env /user:$USER \"$(cygpath -w /usr/bin/mintty.exe)\""
	cygstart -v --hide cmd.exe /c "\"\"%WINDIR%\\system32\\runas.exe\" /savecred /user:$USER \"$(cygpath -w /usr/bin/mintty.exe) $TTYCMD \"\""
else
	cygstart --action=runas "C:\\cygwin64\\bin\\mintty.exe" -h always -e $TTYCMD
fi
