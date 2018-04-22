set -x

# Proxy and modify packets in-flight:
# This replaces the Up arrow key to be Down
netsed tcp 5900 $SERVER 5900 "s/%04%00%00%00%00%00%ff%52/%04%00%00%00%00%00%ff%54" \
  "s/%04%01%00%00%00%00%ff%52/%04%01%00%00%00%00%ff%54"
