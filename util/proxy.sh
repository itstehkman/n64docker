set -x

sed_string=$(ruby gensed.rb)
#sed_string="s/%04%00%00%00%00%00%ff%52/%04%00%00%00%00%00%ff%54/I"
# Proxy and modify packets in-flight
netsed tcp 5900 $SERVER 5900 $sed_string #| grep -v "Caught" | grep -v "Forwarding"
