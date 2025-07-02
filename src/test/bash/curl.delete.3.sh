execId=$1; website=$2
if [ -z "$execId" ] || [ -z "$website" ]; then
	echo "Usage: $0 <execId/> <website/>"
	exit 1
fi

cookie_jar=target/log/cookies/$execId.txt

grep JSESSIONID $cookie_jar

curl -b $cookie_jar  \
 "http://$website/jboss-cluster-ha-demo/delete.jsp" \
 -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
 -H 'Cache-Control: no-cache' \
 -H 'Connection: keep-alive' \
 -H 'Pragma: no-cache' \
 -H 'Upgrade-Insecure-Requests: 1' \
 --insecure \
 -i

