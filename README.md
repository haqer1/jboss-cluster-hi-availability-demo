# jboss-cluster-hi-availability-demo
JBoss (WildfFly) cluster load balancing, sticky sessions &amp; high availability demo

```console
minikube start -p jboss-cluster-hi-availability-demo \
	--addons=metrics-server,ingress,dashboard --memory='5242mb'
```

## 1) Load-Balancing (without sticky sessions or replication)
```console
mvn -Popenshift clean package wildfly:image
pushImageAndTag=adazes/jboss-cluster-sticky-sessions-demo:0.8
docker tag jboss-cluster-ha-demo:latest $pushImageAndTag
docker login -u adazes docker.io
docker push $pushImageAndTag
```

Verify tag in helm file:

```console
head -n 3 src/main/k8s/helm/jboss-cluster-sticky-sessions-demo/charts/service.yaml
```

Install the image (same image is used for sticky-sessions approach (section 2)):

```console
sudo $(minikube ip) wildfly-plugin-helm-ingress-demo >> /etc/hosts

helm install jboss-cluster-sticky-sessions-demo \
	-f src/k8s/jboss-cluster-sticky-sessions-demo/charts/service.yaml \
		--repo https://docs.wildfly.org/wildfly-charts wildfly
```

### 1.1) Automated testing
Run test:

```console
mvn -Dtest=resat.sabiq.jboss.cluster.hi.availability.demo.NoStickySessionNoReplicationTest test
```

View logs (optional):

```shell
cat target/log/curl.put.$(cat target/log/testExecId.txt).log

tail -f target/log/curl.$(cat target/log/testExecId.txt).log
```

## 2) Sticky Sessions (without replication)
It's possible to expose the deployment as a new service:

```console
kubectl expose deployment jboss-cluster-sticky-sessions-demo --type=NodePort --port=8080 --name=jboss-cluster-sticky-sessions-4-deployment-demo
```

And then one can add ingress for sticky-sessions on the basis of the code deployed in prior section, exposed as a new service above:

```console
sudo $(minikube ip) sticky-sessions-ingress-demo >> /etc/hosts

kubectl apply -f src/main/k8s/ingress/sticky-sessions.yaml
```
Wait until address is displayed for *jboss-cluster-sticky-session-ingress* in the 1st of the following
	commands' output:

```console
while [ -z "$ip" ]; do sleep .5 && \
	ip=$(kubectl describe ingress jboss-cluster-sticky-session-ingress | \
		grep Address: | grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}"); \
						done && echo $ip
kubectl get ingress
```

### 2.1) Automated testing
Run test:

```console
mvn -Dtest=resat.sabiq.jboss.cluster.hi.availability.demo.StickySessionsTest test
```

> [INFO] Running resat.sabiq.jboss.cluster.hi.availability.demo.StickySessionsTest  
target/log/curl.20250630-163848.log  
Analyzing results...  
[/bin/sh, -c, grep "*Resat est très bon*" target/log/curl.20250630-163848.log | wc -l]
Matches: 50  
50/50=100,00 %  
[INFO] **Tests run: 2**, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 101.7 s

View logs (optional):

```shell
cat target/log/curl.put.$(cat target/log/testExecId.txt).log

tail -f target/log/curl.$(cat target/log/testExecId.txt).log
```

