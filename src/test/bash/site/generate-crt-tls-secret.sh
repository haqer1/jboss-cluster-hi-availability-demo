subdomain=jboss-replication-ha-demo
domain=$subdomain.francecentral.cloudapp.azure.com
crt_dir=src/test/certificate

makeCrt=$1
makeSecret=$2
if [ $makeCrt -ne 0 ]; then
	mkdir -p src/test/certificate
	openssl req -x509 -nodes -days 1825 -newkey rsa:2048 -keyout $crt_dir/$domain.key \
		-out $crt_dir/$domain.crt -subj "/CN=$domain/O=$subdomain"
fi

if [ -z "$makeSecret" ] || [ $makeSecret -ne 0 ]; then
	kubectl create secret tls $subdomain-tls --key $crt_dir/$domain.key --cert $crt_dir/$domain.crt \
		-n containerized-apps
fi