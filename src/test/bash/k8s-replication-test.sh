execId=$1; request_count=$2; website=$3
if [ -z "$execId" ]; then
	echo "Usage: $0 <execId/>"
	exit 1
fi

if [ -z "$website" ]; then
	website=load-balancing-replication-ingress-demo
fi

src/test/bash/cluster-test-template.sh $execId $website $request_count
