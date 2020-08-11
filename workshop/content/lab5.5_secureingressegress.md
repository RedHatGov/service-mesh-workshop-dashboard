# Securing Ingress and Egress
In cases where strict security is required we need to configure specifics around securing ingress and egress traffic. Security around egress is often used to lock down and deny access to potentially harmful resources outside the network. Additionally, it is a good practice to prevent malicious activities from originating from the cluster.

You are probably already familiar with basic ingress security concepts. Essentially, only exposing particular services to be accessible from outside the cluster and using basic TLS/SSL. The service mesh has an ingress router (a standalone Envoy) running by default and we already configured it during the "Deploying an App into the Service Mesh" lab.

An even better way to track/lockdown inbound traffic for our microservices is to leverage API management in front of all the API services. We could do this with a service mesh plugin for 3scale. We aren't going to walk through it today - if that's something that interest you, [read more about that here][7] [and here][8].

For now let's lockdown egress.

## Lock Down Egress
In this example we are going to restrict access to external endpoints to only approved hosts. The service mesh has an egress router (a standalone Envoy) running by default and we just need to configure it.

The `ServiceMeshControlPlane` custom resource we used to install Istio has a `global` config which allows control of the defaults for egress security. That looks like this:

```
# Set the default behavior of the sidecar for handling outbound traffic from the application:
# ALLOW_ANY - outbound traffic to unknown destinations will be allowed, in case there are no
#   services or ServiceEntries for the destination port
# REGISTRY_ONLY - restrict outbound traffic to services defined in the service registry as well
#   as those defined through ServiceEntries  
outboundTrafficPolicy:
  mode: REGISTRY_ONLY
```

The mesh you're using in this workshop should already have the mode set to `REGISTRY_ONLY`. Let's verify that in the auto-generated config map:

<blockquote>
<i class="fa fa-terminal"></i>
Run this command and look for outboundTrafficPolicy
</blockquote>

```execute
oc describe cm/istio -n istio-system
```

<br>

<blockquote>
<i class="fa fa-terminal"></i>
Now let's verify it's working - Run this command to scrape some data:
</blockquote>

```execute
curl context-scraper.$PROJECT_NAME:8080/scrape/custom_search?term==skynet | jq
```

We should get an output similar to the one below, with error of ECONNRESET:

```
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   682  100   682    0     0  42590      0 --:--:-- --:--:-- --:--:-- 45466
{
  "oops": {
    "name": "RequestError",
    "message": "Error: read ECONNRESET",
    "cause": {
      "errno": "ECONNRESET",
      "code": "ECONNRESET",
      "syscall": "read"
    },
    "error": {
      "errno": "ECONNRESET",
      "code": "ECONNRESET",
      "syscall": "read"
    },
    "options": {
      "method": "GET",
      "uri": "https://www.googleapis.com/customsearch/v1/siterestrict",
      "qs": {
        "key": "AIzaSyDRdgirA2Pakl4PMi7t-8LFfnnjEFHnbY4",
        "cx": "005627457786250373845:lwanzyzfwji",
        "q": "=skynet"
      },
      "headers": {
        "user-agent": "curl/7.29.0",
        "x-request-id": "07ce0cef-5b07-9ee7-8565-a9705bfd90b1",
        "x-b3-traceid": "663d4c9ff4336678433857d48c7a8b5b",
        "x-b3-spanid": "433857d48c7a8b5b",
        "x-b3-sampled": "1"
      },
      "json": true,
      "simple": true,
      "resolveWithFullResponse": false,
      "transform2xxOnly": false
    }
  }
}
```

Which is curl trying to talk to the context-scraper microservice (in the mesh). You can see from the error details that the service is trying to get out to googleapis.com but fails.

<br>

<blockquote>
<i class="fa fa-desktop"></i>
(Optional) If you were to look at Kiali now you'd see the request going to a blackhole:
</blockquote>

<img src="images/kiali-egress-blackhole.png" width="1024" class="screenshot"><br/>

<br>

## Allow Egress to Approved Hosts
Now we will be using an Istio API object of type [ServiceEntry][5] to allow controlled egress. After you add this ServiceEntry, our microservices (via their Envoy sidecars) can send traffic to the specified external service as if it was a service in your mesh.

Our ServiceEntry looks like this:
```yaml
apiVersion: networking.istio.io/v1alpha3
kind: ServiceEntry
metadata:
  name: context-scraper-egress
spec:
  hosts:
  - www.googleapis.com
  ports:
  - number: 443
    name: https
    protocol: HTTPS
  resolution: DNS
  location: MESH_EXTERNAL
```

<br>

<blockquote>
<i class="fa fa-terminal"></i>
Apply it with the following command:
</blockquote>

```execute
oc apply -f ./istio-configuration/serviceentry-googleapis.yaml
```

<br>

<blockquote>
<i class="fa fa-terminal"></i>
Try scrape some data again:
</blockquote>

```execute
curl context-scraper.$PROJECT_NAME:8080/scrape/custom_search?term==skynet | jq
```

Now we should get an output similar to the one below - showing results:

```
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  5197  100  5197    0     0    865      0  0:00:06  0:00:06 --:--:--  1157
[
  {
    "link": "https://www.reddit.com/r/DeepBrainChain/comments/8rar5b/deepbrain_chain_launches_skynet_project/",
    "thumbnail": [
      {
        "src": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQrwBIFnOZygv1EKJ1z7TnNeWIfom8Kp0Zgbs6YvM4
DXYP0zvra6GNCnh0",
        "width": "225",
        "height": "225"
      }
    ],
    "title": "DeepBrain Chain Launches ''Skynet Project''— Recruiting AI ...",
    "snippet": "Nov 29, 2017 ... To achieve that, DeepBrain Chain Foundation will activate the ''Skynet Project
'' \non June 15th Beijing time and, recruit AI computing power from ..."
  },
  {
    "link": "https://www.reddit.com/r/Terminator/comments/eo6qgf/what_would_happen_if_skynet_wins_would_they_bu
ild/",
    "thumbnail": [
      {
        "src": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRq6RYcGTf2e6W8pH3h962NB0_0DNTi93EeqEdtktl
mLoALKvdA1rUY_AU",
        "width": "132",
        "height": "92"
      }
    ],
    "title": "What would happen if Skynet wins? Would they build a world for ...",
    "snippet": "Skynet is an accident and many ways an unstable AI, which makes it different \nfrom the termina
tors it created. We get a hint of this in TSCC of a second machine\n ..."
  },
  ...
```

<br>

If we wanted to we could now configure virtual services and destination rules to control traffic to the service entry in a more granular way. The same way we configured traffic for the other services in our mesh. 

And Kiali tracks this ServiceEntry too, let's look at the graph to see how things are visualized.

<br>

<blockquote>
<i class="fa fa-desktop"></i>
(Optional) And now, if your were to open the graph view of Kiali you'd see the external service represented
<br>
</blockquote>

<img src="images/kiali-egress.png" width="1024" class="screenshot"><br/>

<br>

# Summary
Congrats! You successfully locked down egress to known external hosts and configured tracking of that via the Service Mesh. This is an advanced capability of the mesh - and you can read more about managing [ingress here][1] and [egress here][2]. 

A few key highlights are:

* We can lock down egress traffic to only approved external endpoints or services
* We can lock down ingress traffic to only approved external endpoints or services
* We can secure ingress traffic via standard TLS or mutual TLS
* We can leverage 3scale API management to limit who can access exposed APIs and how


[1]: https://istio.io/docs/tasks/traffic-management/ingress/
[2]: https://istio.io/docs/tasks/traffic-management/egress/
[3]: https://istio.io/docs/ops/best-practices/security/
[4]: https://istio.io/docs/tasks/traffic-management/ingress/secure-ingress-mount/
[5]: https://istio.io/docs/concepts/traffic-management/#service-entries
[6]: https://archive.istio.io/v1.4/docs/tasks/traffic-management/egress/egress-control/
[7]: https://docs.openshift.com/container-platform/4.3/service_mesh/threescale_adapter/threescale-adapter.html
[8]: https://www.redhat.com/en/technologies/jboss-middleware/3scale
