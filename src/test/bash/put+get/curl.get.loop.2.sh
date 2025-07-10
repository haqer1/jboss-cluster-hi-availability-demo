execId=$1; website=$2; request_count=$3
if [ -z "$execId" ] || [ -z "$website" ]; then
	echo "Usage: $0 <execId/> <website/>"
	exit 1
fi
if [ -z "$request_count" ]; then
	request_count=50
fi

website=$(src/test/bash/ensure-http-or-https.sh $website)

logfile=target/log/curl.$execId.log
cookie_jar=target/log/cookies/$execId.txt
grep JSESSIONID $cookie_jar >> $logfile
for i in $(seq 1 $request_count); do echo $i >> $logfile && curl -b $cookie_jar \
   "$website/jboss-cluster-ha-demo/get.jsp" \
   -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
   -H 'Cache-Control: no-cache' \
   -H 'Connection: keep-alive' \
   -H 'Pragma: no-cache' \
   -H 'Upgrade-Insecure-Requests: 1' \
   --insecure \
   -i >> $logfile \
   && sleep .9; \
   done
