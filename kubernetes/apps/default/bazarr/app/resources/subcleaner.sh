#!/usr/bin/env bash

printf "Cleaning subtitles for '%s' ...\n" "$1"
python3 /subcleaner/subcleaner/subcleaner.py "$1" -s

case $1 in
    */anime/*) section="1";;
    */documentaries/*) section="1";;
    */films/*) section="1";;
    */films_uhd/*) section="5";;
    */television/*) section="2";;
    */television_anime/*) section="2";;
    */television_uhd/*) section="9";;
esac

if [[ -n "$section" ]]; then
    printf "Refreshing Plex section '%s' for '%s' ...\n" "$section" "$(dirname "$1")"
    /usr/bin/curl -I -X GET -G \
        --data-urlencode "path=$(dirname "$1")" \
        --data-urlencode "X-Plex-Token=${PLEX_TOKEN}" \
        --no-progress-meter \
            "http://plex.default.svc.cluster.local:32400/library/sections/${section}/refresh"
fi
