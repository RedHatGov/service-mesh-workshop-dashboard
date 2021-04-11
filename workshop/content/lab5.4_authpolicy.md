# Authorizing and Authenticating Access via Policy
In the previous labs we secured and verified the service-to-service communication. But what about user-to-service communication (aka origin authentication)? The service mesh can help with that too. To do this, we need to bring in an identity provider that will issue JSON Web Tokens (JWTs) to signed in users. JWTs are an open, industry standard (RFC 7519) way of sharing identity. The app-ui service will pass those JWTs along with it's API requests. This lets the service mesh's sidecar proxies can verify, get role data, and enforce access.

Let's walk through a basic example of restricting service access via Authentication and Authorization policies.

## Authenticated Users Only
We can lock down the service entirely and only let authenticated users access it.

<blockquote>
<i class="fa fa-terminal"></i> Apply a new authentication policy and service entry with the following commands:
</blockquote>

```execute
 sed "s|%SSO_SVC%|$SSO_SVC|" ./config/istio/request-authentication-boards-jwt.yaml | oc apply -f -
 sed "s|%SSO_SVC%|$SSO_SVC|" ./config/istio/serviceentry-keycloak.yaml | oc apply -f -
```


The policy specifies the requirements for traffic to the boards service to have a JWT with specific properties. It looks like this:
```yaml
apiVersion: "security.istio.io/v1beta1"
kind: RequestAuthentication
metadata:
  name: "boards-jwt"
spec:
  selector:
    matchLabels:
      app: boards
      deploymentconfig: boards
  jwtRules:
  - issuer: "https://keycloak-sso-shared.apps.cluster.domain.com/auth/realms/microservices-demo"
    jwksUri: "https://keycloak-sso-shared.apps.cluster.domain.com/auth/realms/microservices-demo/protocol/openid-connect/certs"

```
<p>
<i class="fa fa-info-circle"></i>
We mentioned earlier that JWT shares identity info, the JWKS endpoint gives us keys to verify the data of the JWT is from our trusted source.
</p>

<p>
<i class="fa fa-info-circle"></i>
Don't worry about the service entry for now - we'll explain that in another lab.
</p>

<br>

<blockquote>
<i class="fa fa-desktop"></i> Goto your webapp and click the Shared navigation button
</blockquote>
<blockquote>
<i class="fa fa-desktop"></i> Refresh the page a few times and try to add something to the shared board
</blockquote>

It will fail with the following error (once it takes effect).

<img src="images/app-boardsshared-failedget.png" width="1024" class="screenshot"><br/>

<br>

<blockquote>
<i class="fa fa-desktop"></i> Login as user "demo" with password "demo"
</blockquote>

<blockquote>
<i class="fa fa-desktop"></i> Try to access the page again
</blockquote>

You should now see a list of shared items

<img src="images/app-boardsshared-successget.png" width="1024" class="screenshot"><br/>


<p><i class="fa fa-info-circle"></i>
You might need to refresh the page a few times before it takes effect
</p>


<br>
<br>

## Only The Cool Kids
In this scenario we want to further secure access to the shared boards list so only a certain group of users can post to it. And we will do this this purely via the Service Mesh configuration. It's pretty straightforward to do.

<blockquote>
<i class="fa fa-terminal"></i> Apply an authorization policy with the following command:
</blockquote>

```execute
oc create -f ./config/istio/authorization-boards-shared-lockdown.yaml
```

That configuration looks like this:
```yaml
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: boards-shared-lockdown
spec:
  selector:
    matchLabels:
      app: boards
      deploymentconfig: boards
  rules:
  - from:
    - source:
        requestPrincipals: ["*"]
    to:
    - operation:
        methods: ["POST"]
        paths: ["*/shareditems"]
    when:
    - key: request.auth.claims[realm_access_roles]
      values: ["cool-kids"]
  - from:
    - source:
        requestPrincipals: ["*"]
    to:
    - operation:
        methods: ["GET"]
    when:
    - key: request.auth.claims[scope]
      values: ["openid"]
```

An authorization policy includes a selector and a list of rules. The selector specifies the **target** that the policy applies to - in this case our boards microservice. While the rules specify **who** (from) is allowed to do **what** (to) under **which** (when) conditions - in this case any source can POST as long as they have the "cool-kids" role listed in their JWT payload. 

So, now that we've applied it, let's try to access your boards service when you're not in the cool kids club.

<br>

<blockquote>
<i class="fa fa-desktop"></i> Goto your webapp and shared page of the website
</blockquote>
<blockquote>
<i class="fa fa-desktop"></i> Try to add something to the shared board
</blockquote>

You should be able to see the items, but posting will fail with the following error.

<blockquote>
<i class="fa fa-desktop"></i> If you're still able to post, wait a minute for the rule to take effect.
</blockquote>

<img src="images/app-boardsshared-failedpost.png" width="1024" class="screenshot"><br/>

<br>

<blockquote>
<i class="fa fa-desktop"></i> Now login as user "theterminator" with password "illbeback"
</blockquote>

<blockquote>
<i class="fa fa-desktop"></i> Try again to add something to the shared board
</blockquote>

Your new item should show in the shared list 

<img src="images/app-boardsshared-successpost.png" width="1024" class="screenshot"><br/>

<br>

<blockquote>
<i class="fa fa-terminal"></i> Now let's put things back to normal
</blockquote>

```execute
oc delete authorizationpolicy/boards-shared-lockdown
```

```execute
oc delete requestauthentication/boards-jwt
```

```execute
oc delete serviceentry/keycloak-egress
```


## How it Works
Our app-ui microservice gets the JWT from the Keycloak SSO whenever a user logs in. If logged in, the JWT is always passed (in the request header) from the app-ui to any services it calls. All our services have Envoy sidecar proxies running and are seeing the traffic, including the JWT in app-ui request headers. So the configuration we applied is used to inform sidecar proxies to follow the policies we set. When we weren't logged in there was no JWT to pass along so our call requests failed. Only after we were logged in with as a valid user did we pass along a valid JWT. And each user's JWT was different, so the *when* conditions only matched for theterminator, allowing him able to POST to the shared board.

If you have the time and want to dig deeper, you should read more about [configuring Keycloak][4] and about [JWTs][3].

Check out high-level diagrams of the flows we executed below:

<br>
*Fail Case*
<img src="images/architecture-jwtfail.png" width="600" class="architecture"><br/>
<br>
*Success Case*
<img src="images/architecture-jwtsuccess.png" width="800" class="architecture"><br/>
<p><i class="fa fa-info-circle"></i>
Note: these diagrams have been simplified for discussion purposes
</p>


## Authorization Policy Summary
* Authorization via dynamically configurable policy
* Secures user-to-service communication
* Utilizes industry standard JSON Web Tokens (JWTs)
* Supports HTTP, HTTPS and HTTP2 natively, as well as any plain TCP protocols
* Policy let's us specify a target, who can do what, and in which condition - [see more examples here][1]
* Pulls some the burden, typically required of individual microservices, up to the platform level and makes it config vs. code

<i class="fa fa-info-circle"></i>
If you have used RBAC prior to 1.4 of Istio you might have noticed that it's a lot easier now. Here's a blog post outlining the differences: https://istio.io/blog/2019/v1beta1-authorization-policy/

[1]: https://archive.istio.io/v1.4/docs/concepts/security/#authorization
[2]: https://www.keycloak.org/docs/latest/server_admin/#_clients
[3]: https://en.wikipedia.org/wiki/JSON_Web_Token
[4]: https://www.keycloak.org/docs/latest/securing_apps/
[5]: https://istio.io/docs/reference/config/policy-and-telemetry/templates/authorization/
