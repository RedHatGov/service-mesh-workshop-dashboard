# Setup

You will conduct these labs in an OpenShift cluster.  First, test you have access to your cluster via console and CLI.

## OpenShift

<blockquote>
<i class="fa fa-desktop"></i> If you check the Console tab in your dashboard, you should see the following:
</blockquote>

<img src="images/openshift-welcome.png" width="1024"><br/>
 *OpenShift Welcome*

<br>

You will use the OpenShift `oc` CLI  to execute commands for the majority of this lab.  


<blockquote>
<i class="fa fa-terminal"></i> You should already be logged in to your cluster in your web terminal.
</blockquote>

Switch to the **Terminal** tab, and try running:

```execute
oc whoami
```
*You can click the play button in the top right corner of the code block to automatically execute the command for you.*

You should see your username: %username%.

The instructor will have preconfigured your projects for you.

<blockquote>
<i class="fa fa-terminal"></i> List your projects:
</blockquote>

```execute
oc projects
```

You should see two projects: your user project (e.g. '%username%') and '%username%-istio'.  

<br>

<blockquote>
<i class="fa fa-terminal"></i> Switch to your user project.  For example:
</blockquote>

```execute
oc project %username%
```

<br>

Let's take a look at the project.

<blockquote>
<i class="fa fa-terminal"></i> List the pods in the project:
</blockquote>

```execute
oc get pods
```

Output (sample):

```
NAME                                    READY   STATUS    RESTARTS   AGE
app-ui-1-build                          0/1     Completed   0        15h
app-ui-1-deploy                         0/1     Completed   0        15h
app-ui-1-xxxxx                          2/2     Running     0        15h
boards-1-xxxxx                          2/2     Running     0        15h
boards-1-build                          0/1     Completed   0        15h
boards-1-deploy                         0/1     Completed   0        15h
boards-mongodb-1-deploy                 0/1     Completed   0        15h
boards-mongodb-1-xxxxx                  2/2     Running     0        15h
context-scraper-1-build                 0/1     Completed   0        15h
context-scraper-1-deploy                0/1     Completed   0        15h
context-scraper-1-xxxxx                 2/2     Running     0        15h
rhsso-operator-xxxxxxxxx-xxxxx          1/1     Running     0        15h
userprofile-1.0-1-build                 0/1     Completed   0        15h
userprofile-xxxxxxxxxx-xxxxx            2/2     Running     0        15h
userprofile-postgresql-1-deploy         0/1     Completed   0        15h
userprofile-postgresql-1-xxxxx          2/2     Running     0        15h
```

<br>

To access the application, you need the endpoint of your load balancer.

<blockquote>
<i class="fa fa-terminal"></i>
Retrieve the URL of the load balancer:
</blockquote>

```execute
GATEWAY_URL=$(oc get route istio-ingressgateway -n %username%-istio --template='http://{{.spec.host}}')
echo $GATEWAY_URL
```

<blockquote>
<i class="fa fa-desktop"></i>
Navigate to this URL in a new browser tab.  For example:
</blockquote>

```
http://istio-ingressgateway-userx-istio.apps.cluster-naa-xxxx.naa-xxxx.example.opentlc.com:6443
```

<br>

You should see the application user interface.  Try creating a new board and posting to the shared board.

For example:

<img src="images/app-pasteboard.png" width="1024"><br/>
 *Create a new board*

## Application Code
Next we need a local copy of our application code.

<blockquote>
<i class="fa fa-terminal"></i> Clone the repository:
</blockquote>

```execute
git clone https://github.com/RedHatGov/service-mesh-workshop-code.git
```

<blockquote>
<i class="fa fa-terminal"></i> Checkout the workshop-stable branch:
</blockquote>

```execute
cd service-mesh-workshop-code && git checkout workshop-stable
```

## Istio
Istio should have been installed in the cluster by the instructor.  Let's make sure it is running in the cluster.  

The %username%-istio project is a service mesh dedicated to you.

<blockquote>
<i class="fa fa-terminal"></i> List the pods in the service mesh project:
</blockquote>

```execute
oc get pods -n %username%-istio
```

Output:

```
NAME                                      READY   STATUS    RESTARTS   AGE
grafana-xxxxxxxxx-xxxxx                   2/2     Running   0          5h30m
istio-egressgateway-xxxxxxxx-xxxxx        1/1     Running   0          5h30m
istio-ingressgateway-xxxxxxxxx-xxxxx      1/1     Running   0          5h30m
istio-telemetry-xxxxxxxxx-xxxxx           2/2     Running   0          5h25m
istiod-workshop-install-xxxxxxxxx-xxxxx   1/1     Running   0          5m28s
jaeger-xxxxxxxxxx-xxxxx                   2/2     Running   0          5h25m
kiali-xxxxxxxxxx-xxxxx                    1/1     Running   0          5h25m
prometheus-xxxxxxxxx-xxxxx                2/2     Running   0          5h30m
```

The primary control plane component is the Istio daemon `istiod`.  `istiod` handles [Traffic Management][1], [Telemetry][2], and [Security][3].  The `istio-ingressgateway` is a load balancer for your service mesh.  You will configure this with a microservices application in the next lab.

[1]: https://istio.io/docs/concepts/traffic-management/
[2]: https://istio.io/docs/concepts/observability/
[3]: https://istio.io/docs/concepts/security/
