website=$1
if [ -z "$website" ]; then
	echo "Usage: $0 <website/>"
	exit 1
fi
if [[ ! $website =~ ^http ]]; then
	website="http://$website"
fi
echo $website