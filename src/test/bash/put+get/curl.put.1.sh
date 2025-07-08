execId=$1; website=$2
if [ -z "$execId" ] || [ -z "$website" ]; then
	echo "Usage: $0 <execId/> <website/>"
	exit 1
fi
#execId=$(date +%y%m%d_%H%M%S)

put_logfile=target/log/curl.put.$execId.log
cookie_jar=target/log/cookies/$execId.txt

grep JSESSIONID $cookie_jar >> $put_logfile

curl -b $cookie_jar -c $cookie_jar \
 "http://$website/jboss-cluster-ha-demo/put.jsp?dev=Resat&qualification=est%20tr%C3%A8s%20bon,%20y%20compris%20en%20clustering%20(grappelage)." \
 -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \
 -H 'Cache-Control: no-cache' \
 -H 'Connection: keep-alive' \
 -H 'Pragma: no-cache' \
 -H 'Upgrade-Insecure-Requests: 1' \
 --insecure \
 -i >> $put_logfile
while [ ! -f $cookie_jar ]; do
	echo Waiting for $cookie_jar >> $put_logfile
	sleep .3
done
