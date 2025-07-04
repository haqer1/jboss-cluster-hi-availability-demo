# JBoss Cluster High Availability Demo
This demo covers the topics of clustering, load balancing, sticky sessions &amp; high availability
on JBoss (WildfFly).

The demo app puts cookies in session in put.jsp, & then tests that they can be retrieved in get.jsp,
in the context of clusters with several server containers.

```console
systemctl status docker.service # confirm that Docker service has been started
minikube start -p jboss-cluster-hi-availability-demo \
	--addons=metrics-server,ingress,dashboard --memory='5242mb' # start k8s
minikube profile jboss-cluster-hi-availability-demo # set profile
```

Before reading any or all of the 4 sections, please keep in mind that during or after automated
testing doable in each of the 4 sections you can optionally **view logs** as follows:

```shell
cat target/log/curl.put.$(cat target/log/testExecId.txt).log

tail -f target/log/curl.$(cat target/log/testExecId.txt).log # or vim ...
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
Optional alternative, in which case you would need to adjust
src/main/k8s/helm/jboss-cluster-sticky-sessions-demo/charts/service.yaml.

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

One can be notified as soon as the deployment is ready to use by running something like the
following command:

```console
while \
    running=$(kubectl get pods -o \
        jsonpath="{.items[*].status.containerStatuses[*].state}" | \
            grep running); \
    [ -z "$running" ]; \
    do sleep .5; done && echo $running
```

### 1.3) Automated testing
Run test:

```console
mvn -Dtest=resat.sabiq.jboss.cluster.hi.availability.demo.NoStickySessionNoReplicationTest test
```

> [INFO] Running resat.sabiq.jboss.cluster.hi.availability.demo.[NoStickySessionNoReplicationTest](src/test/java/resat/sabiq/jboss/cluster/hi/availability/demo/NoStickySessionNoReplicationTest.java)  
/home/ek/development/projects/sandbox/demo/jboss-cluster-hi-availability-demo  
target/log/curl.20250701-112207.log  
Analyzing results...  
[/bin/sh, -c, grep "*Resat est très bon*" target/log/curl.20250701-112207.log | wc -l]  
Matches: 24  
Success rate < 100% as expected for 50 requests: 48,00 %  
[INFO] **Tests run: 1**, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 48.71 s

### 1.4) Using from browser
You can also use the webapp
[from browser](http://wildfly-plugin-helm-ingress-demo/jboss-cluster-ha-demo): however, after
setting the data, it will only show up in get.jsp if the container host(name) is the same as that
having been shown on put.jsp **and** the cookie used while setting the data is passed on to get.jsp.
So, e.g., if data is set by host 10.244.0.10 & load-balancing dispatches get.jsp request to host
10.244.0.9, that different host will not have the data **&** will respond with a different cookie,
so even subsequent get.jsp requests dispatched to host 10.244.0.10 will no longer find the data.
This is why it's much better to test these kinds of things with tools like cUrl, which is what the
automated test does (just like those in the subsequent sections). And this issue encountered with
plain load-balancing is resolved by both sticky sessions approach & replication approach, discussed
in sections 2) & 3)...

### 1.5) Video
Feel free to also (download and) take a look at a WEBM
[video](https://github.com/haqer1/jboss-cluster-hi-availability-demo/raw/refs/heads/master/assets/video/1.load-balancing-demo.webm "Load-Balancing demo WEBM video")
(11m 54s) providing an illustration of the steps in this section (the 1st of 4).

## 2) Sticky Sessions (without replication)

One can add ingress for sticky-sessions on the basis of the code deployed in prior section  
(there is slightly different way with additional kubectl expose step, but this way is better):

```console
sudo $(minikube ip) sticky-sessions-ingress-demo >> /etc/hosts

kubectl apply -f src/main/k8s/ingress/sticky-sessions.yaml
```
Wait until address is displayed for *jboss-cluster-sticky-session-ingress* in the 1st of the
	following commands' output:

```console
while [ -z "$ip" ]; do sleep .5 && \
	ip=$(kubectl describe ingress jboss-cluster-sticky-session-ingress | \
		grep Address: | grep -E "([0-9]{1,3}\.){3}[0-9]{1,3}"); \
						done && echo $ip
kubectl get ingress
```

### 2.1) Automated testing
Run tests:

```console
mvn -Dtest=resat.sabiq.jboss.cluster.hi.availability.demo.StickySessionsTest test
```

> [INFO] Running resat.sabiq.jboss.cluster.hi.availability.demo.[StickySessionsTest](src/test/java/resat/sabiq/jboss/cluster/hi/availability/demo/AbstractStickySessionsOrReplicationTestBase.java)  
target/log/curl.20250630-163848.log  
Analyzing results...  
[/bin/sh, -c, grep "*Resat est très bon*" target/log/curl.20250630-163848.log | wc -l]
Matches: 50  
50/50=100,00 %  
[INFO] **Tests run: 2**, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 101.7 s

### 2.2) Using from browser
You can also use the webapp
[from browser](http://sticky-sessions-ingress-demo/jboss-cluster-ha-demo): after setting the data in
put.jsp, all subsequent requests (to get.jsp, etc.) will be dispatched to the same server
container (based on cookie-based affinity)...

### 2.3) Video
Feel free to also (download and) take a look at a WEBM
[video](https://github.com/haqer1/jboss-cluster-hi-availability-demo/raw/refs/heads/master/assets/video/2.sticky-sessions-demo.webm "Sticky Sessions demo WEBM video")
(11m 11s) providing an illustration of the steps in this section (the 2nd of 4).

## 3) Replication
One might want to (re)build build the app, in case there have been any changes (or build it for the
1st time). For instance, if sticky-sessions setup is there via:

```console
mvn -Dtest=resat.sabiq.jboss.cluster.hi.availability.demo.StickySessionsTest -Popenshift \
	clean package wildfly:image
```

If sticky-sessions setup isn't there, or if one wishes to skip sticky-sessions-based test, one can
(re)build it via:

```console
mvn -DskipTests -Popenshift clean package wildfly:image
```
Then build the app container Docker image using 1 of the 2 following commands:

```console
src/main/docker/jboss-cluster-replication-demo_on_widlfly/build.sh

docker build -f src/main/docker/jboss-cluster-replication-demo_on_widlfly/Dockerfile \
	--tag jboss-cluster-hi-availability-demo:0.8 .
```

Then build the nginx-based load-balancer Docker image:

```console
src/main/docker/nginx-load-balancer/build.sh
```

If you've installed helm-based service (section 1) & sticky-sessions-based ingress (section 2), you
can uninstall them before proceeding:

```console
kubectl delete -f src/main/k8s/ingress/sticky-sessions.yaml # or kubectl delete ingress jboss-cluster-sticky-session-ingress
helm uninstall jboss-cluster-sticky-sessions-demo
```
### 3.1) Publication
I published it as follows (& you could skip this step & just use the published artifact):

```console
imageAndTag=jboss-cluster-hi-availability-demo:0.8

docker tag $imageAndTag adazes/$imageAndTag

docker login -u adazes docker.io

docker push adazes/$imageAndTag
```
#### 3.1.1) Local publication
Optional alternative, in which case you would need to adjust
src/main/k8s/replication-HA/namespace+deployment+service.yaml
(for Kubernetes-based solution (section 3.3)).

```console
minikube addons enable registry

kubectl port-forward --namespace kube-system service/registry 5000:80 &

docker tag jboss-cluster-hi-availability-demo:0.7 localhost:5000/jboss-cluster-hi-availability-demo:0.7

docker push localhost:5000/jboss-cluster-hi-availability-demo:0.7
```

### 3.2) Replication on Pure Docker
Standalone HA config is used here.

You can deploy pure-Docker-based replication solution (with a cluster of 3 server containers)
using the following command:

```console
src/test/bash/network+wildfly+nginx-load-balancer.sh
```

#### 3.2.1) Automated testing
Run tests:

```console
mvn -Dtest=resat.sabiq.jboss.cluster.hi.availability.demo.PureDockerBasedReplicationTest test
```

> [INFO] Running resat.sabiq.jboss.cluster.hi.availability.demo.[PureDockerBasedReplicationTest](src/test/java/resat/sabiq/jboss/cluster/hi/availability/demo/PureDockerBasedReplicationTest.java)  
target/log/curl.20250703-223735.log  
Analyzing results...  
[/bin/sh, -c, grep "*Resat est très bon*" target/log/curl.20250703-223735.log | wc -l]  
Matches: 50  
50/50=100,00 %  
first server IP: 172.28.5.4  
first server load ratio=0.34 vs. min. 0.3 & max. 0.36666667 (requests handled: 17)  
[INFO] **Tests run: 2**, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 46.74 s

#### 3.2.2) Using from browser
You can also use the webapp
[from browser](http://172.17.0.1/jboss-cluster-ha-demo): after setting the data in put.jsp, the data
will be available for subsequent requests (to get.jsp, etc.) on all server containers in the cluster
(thanks to replication)...

#### 3.2.3) Video
Feel free to also (download and) take a look at a WEBM
[video](https://github.com/haqer1/jboss-cluster-hi-availability-demo/raw/refs/heads/master/assets/video/3.2.replication-pure-Docker-demo.webm "Replication on pure Docker demo WEBM video")
(14m 28s) providing an illustration of the steps in this sub-section (the 3rd of 4) (this being the
1st of 3 videos for section 3).

### 3.3) Replication on Kubernetes
Standalone full HA config is used here: "full" meaning webapps, persistence, EJB, JMS, etc. The
same can be done in domain mode also, but would require just a little bit more effort. This approach
could be considered to be between, for instance, Spring Boot on one hand & traditional domain setups
on the other (appearing quite close to Spring Boot end of the continuum)...

Before starting, you can stop & remove pure-Docker-based replication solution using the following command:

```console
src/test/bash/network+wildfly+nginx-load-balancer.undeploy.sh
```
> wildfly-nginx:0.3 5dbcc300e92b  
5dbcc300e92b  
jboss-cluster-hi-availability-demo:0.8 57a736046ad1  
57a736046ad1  
jboss-cluster-hi-availability-demo:0.8 998463aff31e  
998463aff31e  
jboss-cluster-hi-availability-demo:0.8 c8cde33b3230  
c8cde33b3230  
	(doesn't match, skipped: f0d16be9d749)

You can deploy the Kubernetes-based solution (with a cluster of 2 server containers)
using the following command:

```console
kubectl apply -f src/main/k8s/replication-HA/namespace+deployment+service.yaml
```
> namespace/containerized-apps created  
deployment.apps/jboss-cluster-hi-availability-demo created  
service/jboss-cluster-hi-availability-service-demo created

Confirm deployments' status via commands like
(the 3rd one letting know as soon as the solution is ready to use):

```console
kubectl get all -n containerized-apps

minikube service list

while \
	running=$(kubectl get pods -o \
		jsonpath="{.items[*].status.containerStatuses[*].state}" -n containerized-apps | \
			grep running); \
	[ -z "$running" ]; \
	do sleep .5; done && echo $running
```

#### 3.3.1) Ingress for load-balancing (optional, but otherwise running a script is required)
For Ingress-based load-balancing & website mapping one can run:

```console
sudo $(minikube ip) load-balancing-replication-ingress-demo >> /etc/hosts

kubectl apply -f src/main/k8s/ingress/load-balancing.yaml
```

One can run this command to get notified as soon as Ingress is ready:

```console
while domain=$(kubectl get ingress jboss-cluster-replication-ingress \
		-n containerized-apps -o jsonpath="{.status.loadBalancer.ingress[0].ip}"); \
	[ -z "$domain" ]; \
	do sleep .5; done && echo $domain
```

If one skips the 2 commands in the beginning of this section (3.3.1), one needs to run the following
command for automated testing config:

```console
website=$(minikube ip):$(kubectl get service jboss-cluster-hi-availability-service-demo \
	-o jsonpath="{.spec.ports[0].nodePort}" -n containerized-apps)
sed -i "s/^\(website=\).*/\\1${website}/" src/test/bash/k8s-replication-test.sh
```

#### 3.3.2) Automated testing
Once the deployment is operational (with Ingress or adjusted testing config as discussed in the
previous section), one can run the tests:

```console
mvn -Dtest=resat.sabiq.jboss.cluster.hi.availability.demo.KubernetesBasedReplicationTest test
```

As we can see in the following sub-sections, the results are similar with and without Ingress
perhaps also due to the fact that the service itself is of `type: LoadBalancer`. That said, in
production one would be more likely to use Ingress or something platform-specific...

##### 3.3.2.1) Results without Ingress
> [INFO] Running resat.sabiq.jboss.cluster.hi.availability.demo.[KubernetesBasedReplicationTest](src/test/java/resat/sabiq/jboss/cluster/hi/availability/demo/KubernetesBasedReplicationTest.java)  
target/log/curl.20250701-172147.log  
Analyzing results...  
[/bin/sh, -c, grep "*Resat est très bon*" target/log/curl.20250701-172147.log | wc -l]  
Matches: 50  
50/50=100,00 %  
first server IP: 10.244.0.14  
first server load ratio=0.54 vs. min. 0.45 & max. 0.55 (requests handled: 27)  
[INFO] **Tests run: 2**, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 46.74 s

##### 3.3.2.2) Results with Ingress
> [INFO] Running resat.sabiq.jboss.cluster.hi.availability.demo.[KubernetesBasedReplicationTest](src/test/java/resat/sabiq/jboss/cluster/hi/availability/demo/KubernetesBasedReplicationTest.java)  
target/log/curl.20250704-001921.log  
Analyzing results...  
[/bin/sh, -c, grep "*Resat est très bon*" target/log/curl.20250704-001921.log | wc -l]  
Matches: 50  
50/50=100,00 %  
first server IP: 10.244.0.30  
first server load ratio=0.52 vs. min. 0.45 & max. 0.55 (requests handled: 26)  
[INFO] **Tests run: 2**, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 46.70 s

#### 3.3.3) Using from browser
You can also use the webapp
[from browser](http://load-balancing-replication-ingress-demo/jboss-cluster-ha-demo): just as with
pure Docker solution, after setting the data in put.jsp, the data will be available for subsequent
requests (to get.jsp, etc.) on all server containers in the cluster (thanks to replication)...

#### 3.3.4) Video
Feel free to also (download and) take a look at a WEBM
[video](https://github.com/haqer1/jboss-cluster-hi-availability-demo/raw/refs/heads/master/assets/video/3.3.replication-Kubernetes-demo.webm "Replication on Kubernetes demo WEBM video")
(19m 51s) providing an illustration of the steps in this sub-section (the 3rd of 4) (this being the
2nd of 3 videos for section 3).

### 3.4) Extra Credit: Replication of Data Deletion
There is also delete.jsp, linked as well from the welcome page. Feel free to confirm that deletion
also works as expected, which is especially noteworthy in Replication approach, where deletion also
propagates across the cluster. For instance, you could access the pages via browser (keeping in
mind that for connection to current host to be closed a certain delay (apparently at least 1 minute)
is required between user requests). However, that could be boring... One would probably rather use
commands like the following (here for testing on Kubernetes with Ingress-based load-balancing as
discussed above, but it would also work equally well with pure Docker approach, or without Ingress
for load balancing).

The script calls 1, 2 & 3 of the following snippet make a new session with data (on 1 container) and
then lead to the access to the data across the cluster:

```console
src/test/bash/curl.init-session.0.sh 20250701-232801 load-balancing-replication-ingress-demo \
	&& src/test/bash/put+get/curl.put.1.sh 20250701-232801 load-balancing-replication-ingress-demo #1-2
src/test/bash/put+get/curl.get.loop.2.sh 20250701-232801 load-balancing-replication-ingress-demo 4 #3

cat target/log/curl.20250701-232801.log
```

The log output by the last command confirms data replication across the cluster:

```html
load-balancing-replication-ingress-demo	FALSE	/jboss-cluster-ha-demo	FALSE	0	JSESSIONID	ujXREpahv1Z3ohtYK3ebgRWqHBzjNlniK10cHyOj.jboss-cluster-hi-availability-demo-b9767db86-nhgsl
1
HTTP/1.1 200 OK
Date: Tue, 01 Jul 2025 21:32:17 GMT
Content-Type: text/html;charset=UTF-8
Content-Length: 870
Connection: keep-alive
X-Powered-By: JSP/3.1


<html lang="fr">
    <head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<link rel="stylesheet" href="include/css/simple.css" type="text/css" />
     </head>
    <body>
	<h2>Lecture depuis session</h2>
<table>
    <caption>Serveur</caption>
    <tr>
	<th>Adresse IP</th><th>Nom hôte</th>
    </tr>
    <tr>
	<td class="value">10.244.0.13</td>
	<td class="value">jboss-cluster-hi-availability-demo-b9767db86-nhgsl</td>
    </tr>
</table>
<table>
    <caption>Attributs session</caption>
    <tr>
	<th>Attribut(s)</th><th>Valeur(s)</th>
    </tr>
    <tr>
	
	<td>(Date &amp;) Heure (de session)</td>
	<td class="value">Tue Jul 01 21:29:25 GMT 2025</td>
    </tr>
    <tr>
	<td>Développeur &amp; qualification</td>
	<td class="value">Resat est très bon, y compris en clustering (grappelage).</td>
    </tr>
</table>
    </body>
</html>
2
HTTP/1.1 200 OK
...
	<td class="value">10.244.0.14</td>
...
	<td>Développeur &amp; qualification</td>
	<td class="value">Resat est très bon, y compris en clustering (grappelage).</td>
...
```
The script calls C & D of the following snippet delete the data (on 1 container) and then
lead to the attempts to access to the data across the cluster:

```console
last_line_number=$(wc -l target/log/curl.20250701-232801.log | cut -d ' ' -f 1) #A
((last_line_number++)) #B
src/test/bash/curl.delete.3.sh 20250701-232801 load-balancing-replication-ingress-demo #C
src/test/bash/put+get/curl.get.loop.2.sh 20250701-232801 load-balancing-replication-ingress-demo 4 #D

sed -n "$last_line_number,\$p" target/log/curl.20250701-232801.log
```

And the (2nd half of the) log output by the last command confirms propagation of data deletion
across the cluster:

	load-balancing-replication-ingress-demo	FALSE	/jboss-cluster-ha-demo	FALSE	0	JSESSIONID	ujXREpahv1Z3ohtYK3ebgRWqHBzjNlniK10cHyOj.jboss-cluster-hi-availability-demo-b9767db86-nhgsl
	1
	HTTP/1.1 200 OK
	Date: Tue, 01 Jul 2025 21:38:45 GMT
	Content-Type: text/html;charset=UTF-8
	Content-Length: 797
	Connection: keep-alive
	X-Powered-By: JSP/3.1
	
	
	<html lang="fr">
	    <head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<link rel="stylesheet" href="include/css/simple.css" type="text/css" />
	     </head>
	    <body>
		<h2>Lecture depuis session</h2>
	<table>
	    <caption>Serveur</caption>
	    <tr>
		<th>Adresse IP</th><th>Nom hôte</th>
	    </tr>
	    <tr>
		<td class="value">10.244.0.14</td>
		<td class="value">jboss-cluster-hi-availability-demo-b9767db86-mwnsn</td>
	    </tr>
	</table>
	<table>
	    <caption>Attributs session</caption>
	    <tr>
		<th>Attribut(s)</th><th>Valeur(s)</th>
	    </tr>
	    <tr>
		<td>(Date &amp;) Heure (de session)</td>
		<td class="value">null</td>
	    </tr>
	    <tr>
		<td>Développeur &amp; qualification</td>
		<td class="value">null null</td>
	    </tr>
	</table>
	    </body>
	</html>
	2
	HTTP/1.1 200 OK
	...
		<td class="value">10.244.0.13</td>
	...
		<td>Développeur &amp; qualification</td>
		<td class="value">null null</td>
	...

#### 3.4.1) Video
Feel free to also (download and) take a look at a WEBM
[video](https://github.com/haqer1/jboss-cluster-hi-availability-demo/raw/refs/heads/master/assets/video/3.4.replication-of-deletion-Kubernetes-demo.webm "Replication of deletion on Kubernetes demo WEBM video")
(6m 19s) providing an illustration of the steps in this sub-section (the 3rd of 4) (this being the
3rd & last of 3 videos for section 3).

## 4) Super-Extra Credit: Scaling (& Retesting)
Scaling up (or, subsequently, down) & retesting is really in the category of super-extra credit, but
here here goes scaling up & restesting anyway. :)

```console
kubectl get pods -o wide -n containerized-apps
```

```shell
NAME                                                 READY   STATUS    RESTARTS   AGE   IP            NODE                                 NOMINATED NODE   READINESS GATES  
jboss-cluster-hi-availability-demo-b9767db86-mwnsn   1/1     Running   0          8h    10.244.0.14   jboss-cluster-hi-availability-demo   <none>           <none>  
jboss-cluster-hi-availability-demo-b9767db86-nhgsl   1/1     Running   0          8h    10.244.0.13   jboss-cluster-hi-availability-demo   <none>           <none>
```

```console
kubectl scale deployments/jboss-cluster-hi-availability-demo --replicas=3 -n containerized-apps
```

> *deployment.apps/jboss-cluster-hi-availability-demo scaled*

```console
kubectl get pods -o wide -n containerized-apps
```

```shell
NAME                                                 READY   STATUS    RESTARTS   AGE   IP            NODE                                 NOMINATED NODE   READINESS GATES
jboss-cluster-hi-availability-demo-b9767db86-mwnsn   1/1     Running   0          8h    10.244.0.14   jboss-cluster-hi-availability-demo   <none>           <none>
jboss-cluster-hi-availability-demo-b9767db86-nhgsl   1/1     Running   0          8h    10.244.0.13   jboss-cluster-hi-availability-demo   <none>           <none>
jboss-cluster-hi-availability-demo-b9767db86-tcvck   1/1     Running   0          4s    10.244.0.15   jboss-cluster-hi-availability-demo   <none>           <none>
```

But one would have to change 2 to 3 in `KubernetesBasedReplicationTest` for the ratio of requests
served by 1 container to be acceptable for the test to pass. The ratio would now be around 33%
rather than 50%. If that's done (e.g., with command i), it passes (command ii below):

```console
sed -i 's/2/3/' src/test/java/resat/sabiq/jboss/cluster/hi/availability/demo/KubernetesBasedReplicationTest.java #i
mvn -Dtest=resat.sabiq.jboss.cluster.hi.availability.demo.KubernetesBasedReplicationTest test #ii
```

> [INFO] Running resat.sabiq.jboss.cluster.hi.availability.demo.**KubernetesBasedReplicationTest**  
target/log/curl.20250702-010807.log  
Analyzing results...  
[/bin/sh, -c, grep "*Resat est très bon*" target/log/curl.20250702-010807.log | wc -l]  
Matches: 50  
50/50=100,00 %  
first server IP: 10.244.0.14  
first server load ratio=0.34 vs. min. 0.3 & max. 0.366666667 (requests handled: 17)  
[INFO] **Tests run: 2**, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 46.82 s

Hope you have had as much fun reading & pondering over this as I have had working on it
& documenting it. :)

Au revoir.
