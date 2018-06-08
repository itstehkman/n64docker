set -x

sed_string=$(ruby gensed.rb)
#sed_string="s/%04%00%00%00%00%00%ff%52/%04%00%00%00%00%00%ff%54/I"
# Proxy and modify packets in-flight
port=`expr 5900 + $PLAYER_NUM`
netsed tcp $port $SERVER 5900 $sed_string | grep -v "Caught" | grep -v "Forwarding"
