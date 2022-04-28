# Mutual TLS
One of the key features of the Service Mesh is its ability to bring additional security to your applications. It does this in several different ways that will be explored in the next few labs. The first of which is a concept known as "Mutual TLS" or mTLS for short.

Imagine a scenario where you are deploying a microservices application and are expecting a lot of PII to flow between the services. In that scenario there are probably all sorts of security requirements to adhere to. One big requirement that's typical (and could cause a lot of consternation on the development/operations team) is to encrypt all service communications. That's going to mean managing and exchanging SSL keys, validating and authenticating, encrypting and decrypting network traffic, and figuring out how to do it in each application stack (Node.js, Java, Go, etc.).

## Current State of No Encryption
Currently, the services you deployed in earlier labs are secured from access by the outside world by standard OpenShift networking/routing. Essentially, there is no ingress route to most services (as it's controlled via the ingress gateway). However, a rogue pod running in the project could snoop on our data and it could even make direct HTTP requests to other services. 

<p><i class="fa fa-info-circle"></i> Make sure to add some items to the shared board if you haven't already done so. </p>

<blockquote>
<i class="fa fa-terminal"></i> let's launch a job using the CLI with to show that:
</blockquote>

```execute
curl http://boards.%username%:8080/shareditems | jq
```

This job executes a direct HTTP curl request for the current shared boards list. It'll print out something similar to this:

```json
[
  {
    "_id": "5e5d75b33396fe0043f63e5c",
    "owner": "anonymous",
    "type": "string",
    "raw": "something goes here",
    "name": "",
    "id": "MNCkr3mK",
    "created_at": "2020-03-02T21:08:03+00:00"
  },
  {
    "_id": "5e5d75b63396fe0043f63e5d",
    "owner": "anonymous",
    "type": "string",
    "raw": "another item",
    "name": "",
    "id": "x5ORoJu8",
    "created_at": "2020-03-02T21:08:06+00:00"
  }
]
```

<br>

## Adding mTLS to Our Existing Services
Now we will show how the Service Mesh can encrypt all traffic without requiring code changes, without complicated networking updates, and without installing/using tools (e.g. ssh-keygen) or servers. We are going to do this with a policy that applies to all services in our app.
<p>
<i class="fa fa-info-circle"></i>
Service mesh allows setting policy at the individual service, namespace, and entire mesh levels (applied/enforced in that order)
</p>

We already wrote the YAML config to do this. It looks like this:
```yaml
apiVersion: "security.istio.io/v1beta1"
kind: "PeerAuthentication"
metadata:
  name: "default"
spec:
  mtls:
    mode: STRICT
```

<blockquote>
<i class="fa fa-terminal"></i> First we apply the policy with the following command:
</blockquote>

```execute
oc create -f ./config/istio/peer-authentication-mtls.yaml
```

Now we also need to set DestinationRules for each service so that our sidecars know to use mTLS when communicating with each other. The YAML for that looks like this - note the use of a wildcard:
```yaml
apiVersion: "networking.istio.io/v1alpha3"
kind: "DestinationRule"
metadata:
  name: "destinationrule-mtls-istio-mutual"
spec:
  host: "*.svc.cluster.local"
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
```

<blockquote>
<i class="fa fa-terminal"></i> Remove existing destination rules:
</blockquote>

```execute
oc delete dr --all
```
<br>

<blockquote>
<i class="fa fa-terminal"></i> Apply it with the following command:
</blockquote>

```execute
oc create -f ./config/istio/destinationrule-mtls.yaml
```

## Verify the App Still Works with mTLS On
So now that the policy is applied, all our service-to-service (aka peer) communication will **require** mTLS.

<blockquote>
<i class="fa fa-desktop"></i> Goto your webapp and refresh the website a few times to send some traffic through our microservices.
</blockquote>
Everything should look just the same as before - the extra security is happening behind the scenes.

<img src="images/app-boardslist.png" width="1024" class="screenshot"><br/>

<br>
Next we will verify the mTLS that we just enabled.
