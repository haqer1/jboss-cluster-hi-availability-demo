execId=$1; website=$2; request_count=$3
if [ -z "$execId" ] || [ -z $website ]; then
	echo "Usage: $0 <execId/> <website/>"
	exit 1
fi

mkdir -p target/log/cookies

src/test/bash/curl.init-session.0.sh $execId $website
sleep .25 # just in case: for cookie file persistance, etc.
src/test/bash/put+get/curl.put.1.sh $execId $website
sleep .25
src/test/bash/put+get/curl.get.loop.2.sh $execId $website $request_count
