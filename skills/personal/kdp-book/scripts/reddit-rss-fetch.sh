#!/bin/bash
# Fetch Reddit search feeds (RSS) for discovery without a browser. Reddit returns 429 on rapid requests, so back off.
# Usage: reddit-rss-fetch.sh <outdir> <subreddit> "<query>" [top|new] [all|year]
# Each <entry> in the feed has <title>, <link href>, <updated> and <content> (post body as escaped HTML).
set -u
OUT="$1"; SUB="$2"; Q="$3"; SORT="${4:-top}"; T="${5:-all}"
UA="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0 Safari/537.36"
mkdir -p "$OUT"
ENC=$(python3 -I -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$Q")
NAME="${SUB}_$(echo "$Q" | tr -c 'A-Za-z0-9' '_')_${T}.xml"
URL="https://www.reddit.com/r/${SUB}/search.rss?q=${ENC}&restrict_sr=on&sort=${SORT}&t=${T}"
for attempt in 1 2 3 4; do
  CODE=$(curl -s -m 30 -A "$UA" -o "$OUT/$NAME" -w "%{http_code}" "$URL")
  if [ "$CODE" = "200" ]; then echo "$SUB|$Q|$T|200|$NAME"; exit 0; fi
  if [ "$CODE" = "429" ]; then sleep $((15 * attempt)); continue; fi
  echo "$SUB|$Q|$T|$CODE|$NAME"; exit 1
done
echo "$SUB|$Q|$T|429-giveup|$NAME"; exit 1
