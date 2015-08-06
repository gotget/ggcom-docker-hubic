#!/usr/bin/env bash
: <<'!COMMENT'

GGCOM - Docker - hubiC v201508061247
Louis T. Getterman IV (@LTGIV)
www.GotGetLLC.com | www.opensour.cc/ggcom/docker/hubic

Thanks:

bash - How to keep quotes in args? - Stack Overflow - Thank you Dennis Williamson!
http://stackoverflow.com/a/1669493

!COMMENT

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

# Did anything get mounted?
if [ ! -f /hubic/credentials.txt ]; then
	echo;
    echo "hubiC credentials not mounted!  Exiting." >&2
	exit 1;
fi

# Did they forget the proper commands?
testCmd=`umount /mnt/hubic 2>&1`
if [ $? -ne 0 ]; then
	case "$testCmd" in
		*"must be superuser to umount"*)
			echo;
			echo "It appears that you forgot to use '--cap-add SYS_ADMIN --device /dev/fuse' when running this container.  Exiting." >&2
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

################################################### Update $HOME/.bashrc
cat << 'EOF' >> $HOME/.bashrc

export PATH=$HOME/bin:$PATH

EOF
###################################################/Update $HOME/.bashrc

echo "\

You are now inside of the hubiC container with your mounted volumes from your host.

Useful commands:

hubic  - mount your hubiC volume.
uhubic - umount your hubiC volume.
config - edit your hubiC configuration.
";

source .bashrc

if [ ! -z "$cmdrun" ]; then
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

/usr/bin/env bash
