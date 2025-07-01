# jboss-cluster-hi-availability-demo
JBoss (WildfFly) cluster load balancing, sticky sessions &amp; high availability demo

```console
minikube start -p jboss-cluster-hi-availability-demo \
	--addons=metrics-server,ingress,dashboard --memory='5242mb'
```

## 1) Load-Balancing (without sticky sessions or replication)

```console
mvn -DskipTests -Popenshift clean package wildfly:image
```

### 1.1) Publication
I published it as follows (& you could skip this step & just use the published artifact):

```console
pushImageAndTag=adazes/jboss-cluster-sticky-sessions-demo:0.7

docker tag jboss-cluster-ha-demo:latest $pushImageAndTag

docker login -u adazes docker.io

docker push $pushImageAndTag
```

#### 1.1.1) Local publication
Optional alternative, in which case you would need to adjust src/main/k8s/helm/jboss-cluster-sticky-sessions-demo/charts/service.yaml.

```console
minikube addons enable registry

kubectl port-forward --namespace kube-system service/registry 5000:80 &

docker tag jboss-cluster-ha-demo:latest localhost:5000/jboss-cluster-ha-demo:latest

docker push localhost:5000/jboss-cluster-ha-demo:latest
```
### 1.2) Installation
Verify tag in helm file:

```console
head -n 3 src/main/k8s/helm/jboss-cluster-sticky-sessions-demo/charts/service.yaml
```

Install the image (same image is used for sticky-sessions approach (section 2)):

```console
sudo $(minikube ip) wildfly-plugin-helm-ingress-demo >> /etc/hosts

helm install jboss-cluster-sticky-sessions-demo \
	-f src/main/k8s/helm/jboss-cluster-sticky-sessions-demo/charts/service.yaml \
		--repo https://docs.wildfly.org/wildfly-charts wildfly
```

### 1.3) Automated testing
Run test:

```console
mvn -Dtest=resat.sabiq.jboss.cluster.hi.availability.demo.NoStickySessionNoReplicationTest test
```

> [INFO] Running resat.sabiq.jboss.cluster.hi.availability.demo.**NoStickySessionNoReplicationTest**  
/home/ek/development/projects/sandbox/demo/jboss-cluster-hi-availability-demo  
target/log/curl.20250701-112207.log  
Analyzing results...  
[/bin/sh, -c, grep "*Resat est très bon*" target/log/curl.20250701-112207.log | wc -l]  
Matches: 24  
Success rate < 100% as expected for 50 requests: 48,00 %  
[INFO] **Tests run: 1**, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 48.71 s

View logs (optional):

```shell
cat target/log/curl.put.$(cat target/log/testExecId.txt).log

tail -f target/log/curl.$(cat target/log/testExecId.txt).log
```

## 2) Sticky Sessions (without replication)

One can add ingress for sticky-sessions on the basis of the code deployed in prior section  
(there is slightly different way with additional kubectl expose step, but this way is better):

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

> [INFO] Running resat.sabiq.jboss.cluster.hi.availability.demo.**StickySessionsTest**  
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

## 3) Replication
First build the app. For instance, if sticky-sessions setup is there via:

```console
mvn -Dtest=resat.sabiq.jboss.cluster.hi.availability.demo.StickySessionsTest -Popenshift clean package wildfly:image
```

If not, via:

```console
mvn -DskipTests -Popenshift clean package wildfly:image
```
Then build Docker image using 1 of the 2 following commands:

```console
src/main/docker/jboss-cluster-replication-demo_on_widlfly/build.sh

docker build -f src/main/docker/jboss-cluster-replication-demo_on_widlfly/Dockerfile --tag jboss-cluster-hi-availability-demo:0.8 .
```

If you've installed helm-based service & sticky-sessions-based ingress, you can uninstall them before proceeding:

```console
kubectl delete ingress jboss-cluster-sticky-session-ingress
helm uninstall jboss-cluster-sticky-sessions-demo
```
#### 3.1) Publication
I published it as follows (& you could skip this step & just use the published artifact):

```console
imageAndTag=jboss-cluster-hi-availability-demo:0.8

docker tag $imageAndTag adazes/$imageAndTag

docker login -u adazes docker.io

docker push adazes/$imageAndTag
```
#### 3.1.1) Local publication
Optional alternative, in which case you would need to adjust src/main/k8s/replication-HA/deployment.yaml.

```console
minikube addons enable registry

kubectl port-forward --namespace kube-system service/registry 5000:80 &

docker tag jboss-cluster-hi-availability-demo:0.7 localhost:5000/jboss-cluster-hi-availability-demo:0.7

docker push localhost:5000/jboss-cluster-hi-availability-demo:0.7
```

### 3.2) Pure Docker
You can deploy pure-Docker-based replication solution using the following command:

```console
src/test/bash/network+wildfly+nginx-load-balancer.sh
```

#### 3.2.1) Automated testing
Run test:

```console
mvn -Dtest=resat.sabiq.jboss.cluster.hi.availability.demo.PureDockerBasedReplicationTest test
```

> [INFO] Running resat.sabiq.jboss.cluster.hi.availability.demo.**PureDockerBasedReplicationTest**  
target/log/curl.20250701-151600.log  
Analyzing results...  
[/bin/sh, -c, grep "*Resat est très bon*" target/log/curl.20250701-151600.log | wc -l]  
Matches: 50  
50/50=100,00 %  
first server IP: 172.28.5.4  
firstServerLoadRatio=0.32 vs. min. 0.23333335 & max. 0.43333334 (requests handled: 16)  
[INFO] **Tests run: 2**, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 46.74 s

View logs (optional):

```shell
cat target/log/curl.put.$(cat target/log/testExecId.txt).log

tail -f target/log/curl.$(cat target/log/testExecId.txt).log
```
