execId=$1; request_count=$2
if [ -z "$execId" ]; then
	echo "Usage: $0 <execId/>"
	exit 1
fi

website=sticky-sessions-ingress-demo
src/test/bash/cluster-test-template.sh $execId $website $request_count