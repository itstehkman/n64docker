set -x

sed_string=$(ruby gensed.rb)
# Proxy and modify packets in-flight
netsed tcp 5900 $SERVER 5900 $sed_string | grep -v "Caught" | grep -v "Forwarding"
