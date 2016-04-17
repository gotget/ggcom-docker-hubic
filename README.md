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
        -v /media/drive1/:/root/drive1/ \
        -v /media/drive2/:/root/drive2/ \
        -v /media/drive3/:/root/drive3/ \
        gotget/hubic

----------

Entering the detached container and using rsync to copy a file:
---------------------------------------------------------------

    docker exec -it hubic bash

    hcp \
      /root/drive1/big-directory/ \
      /root/hubic/big-directory/

**Notes:**

 - `hcp` is an alias to rsync with a long list of options for hubiC compatibility, that was setup with this Docker container, and resides in `~/.bashrc` inside of the Docker container.
 - If you want to use additional utilities inside, mount a volume to `/root/bin/`, as it's set in the container's `$PATH` variable:
	 - `-v /path/to/utilities/:/root/bin/`
 - Additional documents and notes are on my pet project, "[open-sourcey](https://www.opensour.cc/)"

----------

Thanks, and please enjoy.  `:-)`

-[Louis T. Getterman IV](http://Thad.Getterman.org/) ([@LTGIV](https://Twitter.com/LTGIV)) / [GitHub](https://GitHub.com/LTGIV) / [LinkedIn](https://LinkedIn.com/in/LTGIV)

----------

> Written with [StackEdit](https://stackedit.io/).
