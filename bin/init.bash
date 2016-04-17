#!/usr/bin/env bash
: <<'!COMMENT'

GGCOM - Docker - hubiC v201604161440
Louis T. Getterman IV (@LTGIV)
www.GotGetLLC.com | www.opensour.cc/ggcom/docker/hubic

Thanks:

bash - How to keep quotes in args? - Stack Overflow - Thank you Dennis Williamson!
http://stackoverflow.com/a/1669493

To-do:
* unmount at container shutdown (see https://stackoverflow.com/questions/32940887/docker-container-shutdown-script)

!COMMENT

################################################################################

# Attempt to keep quotes in arguments passed to Docker, which is then passed to here.
cmdrun=''
whitespace="[[:space:]]"
for i in "$@"
do
	if [[ $i =~ $whitespace ]]
	then
		i=\"$i\"
	fi
	cmdrun="${cmdrun}${i} "
done
unset i

################################################################################

# Did anything get mounted?
if [ ! -f /root/.hubicfuse ]; then
	echo;
	echo "hubiC credentials not mounted!  Exiting." >&2
	read -t 5 -n 1 -p "$prompt";
	echo;
	exit 1;
fi

################################################################################

# Did they forget the proper commands?
testCmd=`umount /mnt/hubic 2>&1`
if [ $? -ne 0 ]; then
	case "$testCmd" in
		*"must be superuser to umount"*)
			echo;
			echo "It appears that you forgot to use '--privileged' when running this container.  Exiting." >&2
			exit 1;
			;;
		*"not mounted"*)
			# Nothing to do, this is the message that we're hoping for.
			;;
		*)
			echo "An unknown error occurred:" >&2
			echo "$testCmd" >&2
			echo "Exiting." >&2
			exit 1;
	esac
fi
unset testCmd

########################################################### Update $HOME/.bashrc
cat << 'EOF' >> $HOME/.bashrc

export PATH=$HOME/bin:$PATH

alias hcp="rsync \
--archive \
--verbose \
--progress \
--inplace \
--partial \
--delete \
--delete-excluded \
--no-owner \
--no-group \
--no-times \
--rsh=/usr/bin/ssh \
--exclude='.DS_Store' \
--exclude='.git'"

EOF
###########################################################/Update $HOME/.bashrc

#################################################################### Mount hubiC
testCmd=`hubicfuse /mnt/hubic -o noauto_cache,sync_read,allow_other 2>&1`
if [ $? -ne 0 ]; then
	echo "An error has occurred with mounting hubiC:" >&2
	echo "$testCmd" >&2
	echo "Exiting." >&2
	exit 1;
else
	echo "hubiC has been successfully mounted to /root/hubic/"
fi
####################################################################/Mount hubiC

echo "\

You are now inside of the hubiC container with your mounted volumes from your host.

`ls -l /root/hubic/`
";

source .bashrc

if [ ! -z "$(echo -e "${cmdrun}" | tr -d '[[:space:]]')" ]; then
	echo '----------------------------------------';
	echo "Running additional commands:"
	echo "$cmdrun";
	echo '----------------------------------------';
	echo "Results:"
	echo '----------------------------------------';
	eval "$@";
	echo '----------------------------------------';
	echo;
fi

################################################################################

/usr/bin/env bash
