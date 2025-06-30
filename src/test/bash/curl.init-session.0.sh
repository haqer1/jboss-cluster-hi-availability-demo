execId=$1; website=$2
if [ -z "$execId" ] || [ -z "$website" ]; then
	echo "Usage: $0 <execId/> <website/>"
	exit 1
fi

put_logfile=target/log/curl.put.$execId.log
cookie_jar=target/log/cookies/$execId.txt
curl -c $cookie_jar "http://$website/jboss-cluster-ha-demo/index.jsp" \
 -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
 -H 'Cache-Control: no-cache' \
 -H 'Connection: keep-alive' \
 -H 'Pragma: no-cache' \
 -H 'Upgrade-Insecure-Requests: 1' \
 -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 OPR/119.0.0.0' \
 --insecure \
 -i >> $put_logfile
while [ ! -f $cookie_jar ]; do
	echo Waiting for $cookie_jar >> $put_logfile
	sleep .3
done
grep JSESSIONID $cookie_jar >> $put_logfile
