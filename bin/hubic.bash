#!/usr/bin/env bash
: <<'!COMMENT'

GGCOM - Docker - hubiC v201508061247
Louis T. Getterman IV (@LTGIV)
www.GotGetLLC.com | www.opensour.cc/ggcom/docker/hubic

!COMMENT

hubicfuse /mnt/hubic -o noauto_cache,sync_read,allow_other
