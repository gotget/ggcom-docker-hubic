# GGCom : Docker : hubiC

Docker-based encapsulation of the [HubicFuse](https://github.com/TurboGit/hubicfuse) project, allowing you to mount [OVH](https://www.ovh.com/)'s [hubiC](https://hubic.com/en/) as a network share.

----------

Build from Dockerfile:
----------------------

    git clone https://github.com/gotget/ggcom-docker-hubic.git
    cd ggcom-docker-hubic
    docker build -t gotget/hubic .

__or__
--

Pull from [Docker Hub](https://hub.docker.com/):
------------------------------------------------

    docker pull gotget/hubic

----------

Initializing a credentials file:
--------------------------------

**Step 1: Obtain a Client ID and reciprocal Secret Key from hubiC:**

 - Login to the [hubiC Developer API](https://hubic.com/home/browser/developers/) portal.
 - Click on "Add an application"
 - For "Last name", I use the name of the server that I'm configuring this for.
 - For "Redirection domain", I use https://SERVERNAME.example.com/
	 - (I literally use "example.com" for the domain name)
 - Click "OK", and the application will appear in your list.
 - Click on "Details" next to the newly-created entry for application.
 - Copy the Client ID from the text field to use below, for retrieving an access token.
 - Copy the Secret Client from the text field to use below, for retrieving an access token.

**Step 2: Obtain a hubiC access token:**

    docker rm -f hubic
    docker run \
        --rm \
        --interactive --tty \
        --name=hubic-init \
        --entrypoint=/usr/local/bin/hubic_token \
        gotget/hubic

Follow the on-screen instructions, and stick with the defaults in parenthesis if you don't need to change them for a special need.  When finished answering questions, the output will comprise the bulk of your hubiC credentials file that you should save with read-only access by your specific user (probably root) that you're running the Docker as:

**hubicfuse.ini**
```
client_id=api_hubic_ABC123789XYZ
client_secret=ABC123789XYZ
refresh_token=ABC123789XYZ
redirect_uri=https://SERVERNAME.example.com/
verify_ssl=True
```

----------

Testing our setup:
------------------

    docker run \
        --rm \
        --interactive --tty \
        --privileged \
        --name=hubic \
        -v /path/to/hubicfuse.ini:/root/.hubicfuse \
        gotget/hubic

If everything works properly, you should see something along the lines of:

```
hubiC has been successfully mounted to /root/hubic/

You are now inside of the hubiC container with your mounted volumes from your host.

(list of directories and files stored on your hubiC will appear here)

root@abc123789xyz:~#
```

If a failure occurs, then ideally, you'll receive a specific message indicating what went wrong.

----------

Launching a detached container:
-------------------------------

    docker run \
        --detach \
        --interactive --tty \
        --privileged \
        --name=hubic \
        -v /path/to/hubicfuse.ini:/root/.hubicfuse \
        -v /media/drive1/:/mnt/drive1/ \
        -v /media/drive2/:/mnt/drive2/ \
        -v /media/drive3/:/mnt/drive3/ \
        gotget/hubic

----------

Example: processing raw data and sending it to hubiC:
---------------------------------------------------------------

**Enter the hubiC container that's detached and running in the background:**

    docker exec -it hubic bash

**Gather a directory's contents together in an uncompressed file:**

    cd /mnt/drive3/
    tar -cvf largeDirectory.tar ./largeDirectory/

**Split the archive into segments**
*(hubiC seems to choke on anything greater than (or equal to?) a Gigabyte, so we'll split the file into a sequence of files that each measure 950 MegaBytes, sans the last file of the sequence which may be smaller)*

    split \
        --bytes=950M \
        largeDirectory.tar \
        largeDirectory.tar.
(Notice the ending `.`?  This is what separates the name from the sequence that's named as an alphabetical suffix, which would save as: `largeDirectory.tar.aa`, `largeDirectory.tar.ab`, `largeDirectory.tar.ac`, etc.)

**Move split-sequence files to a holding directory:**

    mkdir -pv /mnt/drive3/tmp/
    mv -iv largeDirectory.tar.* /mnt/drive3/tmp/

**Synchronizing with hubiC:**
(You can reverse paths if you want to synchronize from hubiC to your host volume)

    hsync \
      /mnt/drive3/tmp/ \
      /hubic/largeDirectory-split/

----------

Notes:
------

 - `hsync` is an alias to `rsync` with a long list of options for hubiC compatibility, that was setup with this Docker container, and resides in `~/.bashrc` inside of the Docker container.
 - Many extra utilities are packaged into the container:
	 - `cURL` - command-line tool for transferring data using various protocols.
	 - `Duply` (simple `duplicity`) - a frontend that simplifies the use of `Duplicity`.
		 - (requires, and thus, includes `Duplicity`, which provides an encrypted, digitally signed, versioned, remote backup of files requiring little of a remote server)
	 - `EncFS` - FUSE-based cryptographic filesystem.
	 - `Nano` - a text editor for Unix-like computing systems or operating environments using a command line interface.
	 - `rsnapshot` - a filesystem snapshot utility based on rsync (and similar to `Duplicity`, but with less built-in security, and geared more towards trusted environments).
	 - `rsync` - a widely-used utility to keep copies of a file on two (or more) computer systems.
	 - `SSHFS` - SSHFS (SSH Filesystem) is a filesystem client to mount and interact with directories and files located on a remote server or workstation over a normal ssh connection.
 - If you want to use additional utilities inside (e.g. [FMDMS](https://www.opensour.cc/ggcom/start?s%5B%5D=FMDMS#utilities) from [GGCom Bash Utilities](https://github.com/gotget/ggcom-bash-utils/)), mount a volume to `/root/bin/`, as it's set in the container's `$PATH` variable:
	 - `-v /path/to/utilities/:/root/bin/`
 - Additional documents and notes are on my pet project, "[open-sourcey](https://www.opensour.cc/)"

----------

Thanks, and please enjoy.  `:-)`

-[Louis T. Getterman IV](http://Thad.Getterman.org/) ([@LTGIV](https://Twitter.com/LTGIV)) / [GitHub](https://GitHub.com/LTGIV) / [LinkedIn](https://LinkedIn.com/in/LTGIV)

----------

> Written with [StackEdit](https://stackedit.io/).
