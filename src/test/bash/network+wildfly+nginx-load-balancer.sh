docker network create \
 --driver=bridge \
 --subnet=172.28.0.0/16 \
 --ip-range=172.28.5.0/24 \
 --gateway=172.28.5.254 \
 wildnetwork

artifact=jboss-cluster-hi-availability-demo:0.8

docker run -d --name wild1 -h wild1 -p 8090:8080 -p 9990:9990 --network=wildnetwork \
	--ip 172.28.5.2 $artifact /bin/bash -c 'ip=$(awk '"'"'END{print $1}'"'"' /etc/hosts) && \
		/opt/jboss/wildfly/bin/standalone.sh -Djboss.bind.address.management=$ip \
			-Djboss.bind.address=$ip -Djboss.bind.address.private=$ip \
			-Djboss.bind.address.unsecure=$ip -c standalone-full-ha.xml -u 230.0.0.4'
docker run -d --name wild2 -h wild2 -p 8091:8080 -p 9991:9990 --network=wildnetwork \
	--ip 172.28.5.3 $artifact /bin/bash -c 'ip=$(awk '"'"'END{print $1}'"'"' /etc/hosts) && \
		/opt/jboss/wildfly/bin/standalone.sh -Djboss.bind.address.management=$ip \
			-Djboss.bind.address=$ip -Djboss.bind.address.private=$ip \
			-Djboss.bind.address.unsecure=$ip -c standalone-full-ha.xml -u 230.0.0.4'
docker run -d --name wild3 -h wild3 -p 8092:8080 -p 9992:9990 --network=wildnetwork \
	--ip 172.28.5.4 $artifact /bin/bash -c 'ip=$(awk '"'"'END{print $1}'"'"' /etc/hosts) && \
		/opt/jboss/wildfly/bin/standalone.sh -Djboss.bind.address.management=$ip \
			-Djboss.bind.address=$ip -Djboss.bind.address.private=$ip \
			-Djboss.bind.address.unsecure=$ip -c standalone-full-ha.xml -u 230.0.0.4'

docker run -p 172.17.0.1:80:80 --network=wildnetwork --ip 172.28.5.5 wildfly-nginx:0.3