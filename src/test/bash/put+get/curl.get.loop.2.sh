execId=$1; website=$2; request_count=$3
if [ -z "$execId" ] || [ -z "$website" ]; then
	echo "Usage: $0 <execId/> <website/>"
	exit 1
fi
#execId=$(date +%y-%m-%d_%H-%M-%S)
if [ -z "$request_count" ]; then
	request_count=50
fi

logfile=target/log/curl.$execId.log
cookie_jar=target/log/cookies/$execId.txt
grep JSESSIONID $cookie_jar >> $logfile
for i in $(seq 1 $request_count); do echo $i >> $logfile && curl -b $cookie_jar \
   "http://$website/jboss-cluster-ha-demo/get.jsp" \
   -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
   -H 'Cache-Control: no-cache' \
   -H 'Connection: keep-alive' \
   -H 'Pragma: no-cache' \
   -H 'Upgrade-Insecure-Requests: 1' \
   -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36 OPR/119.0.0.0' \
   --insecure \
   -i >> $logfile \
   && sleep .9; \
   done
