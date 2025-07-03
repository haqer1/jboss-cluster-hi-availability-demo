for c in $(docker container ls -q); do
	image=$(docker inspect $c --format "{{.Config.Image}}")
	if [[ $image =~ wildfly-nginx ]] || [[ $image =~ jboss-cluster-* ]]; then
		echo -n "$image "
		docker container stop $c
		docker container rm $c
	else
		echo "	(doesn't match, skipped: $c)"
	fi
done
docker network rm wildnetwork
