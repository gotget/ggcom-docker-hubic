#!/usr/bin/env bash
: <<'!COMMENT'

GGCOM - Docker - hubiC v201508061247
Louis T. Getterman IV (@LTGIV)
www.GotGetLLC.com | www.opensour.cc/ggcom/docker/hubic

To-do:

* To-do: Use tee to grab values if "Success!" message is shown, and dump to configuration automatically.

!COMMENT

# Notice
echo "\

You will need to configure your API keys via hubiC first:
https://hubic.com/home/browser/developers/

Additional configuration information for doing so can be found at:
https://www.opensour.cc/hubic
";

# Obtain refresh token
/usr/local/bin/hubic_token; \

# Edit notice
echo;
echo "Copy the 'client_id', 'client_secret', and 'refresh_token' values for adding to your configuration."
echo;
read -p "Press [Enter] key to launch editor..."

# Editor
eval ${FCEDIT:-${VISUAL:-${EDITOR:-nano}}} $HOME/.hubicfuse

# Notice finish
echo;
echo "Okay, now you can try mounting your hubiC volume using the 'hubic' command."
echo;
