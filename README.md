# OpenShift Service Mesh Workshop
This content has been designed to work with an OpenShift Homeroom deployment. Considerations include:
* Variable interpolation for user or cluster-specific variables in the lab guide content
* Usage of cluster-internal URLs for accessing or testing services with `curl`
* **Kiali** and **Jaeger** are built into the dashboard view for ease of use
    * Because these windows are loaded in HTML iframes, they cannot support OAuth authentication flows. We workaround this by using token-auth in Kiali and no auth in Jaeger.  

## Deploying this workshop
1. Complete [these steps](https://github.com/RedHatGov/service-mesh-workshop-code/tree/workshop-stable/deployment/workshop) **first**
2. Adjust **Kiali** and **Jaeger** as indicated above, then restart **Kiali**
```bash
oc patch -n istio-system kiali kiali -p '{"spec":{"auth":{"strategy":"token"}}}' --type merge
oc patch -n istio-system jaeger jaeger -p '{"spec":{"ingress":{"security":"none"}}}' --type merge
oc rollout restart deployment kiali -n istio-system
```
3. Set a local `CLUSTER_SUBDOMAIN` environment variable
```
CLUSTER_SUBDOMAIN=<apps.openshift.com>
```
4. Grab the template to deploy a `workshop-spawner`. Note that the `CUSTOM_TAB_*` variables take the form `<tabLabel>=<url>` 
```
oc process -f https://raw.githubusercontent.com/RedHatGov/workshop-spawner/develop/templates/hosted-workshop-production.json \
    -p SPAWNER_NAMESPACE=istio-system \
    -p CLUSTER_SUBDOMAIN=$CLUSTER_SUBDOMAIN \
    -p WORKSHOP_NAME=service-mesh-workshop \
    -p CONSOLE_IMAGE=quay.io/openshift/origin-console:4.5 \
    -p WORKSHOP_IMAGE=quay.io/redhatgov/service-mesh-workshop-dashboard:latest \
    -p CUSTOM_TAB_1=Kiali=https://kiali-istio-system.$CLUSTER_SUBDOMAIN \
    -p CUSTOM_TAB_2=Jaeger=https://jaeger-istio-system.$CLUSTER_SUBDOMAIN \
| oc apply -f -
```
5. Give this URL (or preferably a shortened version) to your workshop attendees:
```
echo https://service-mesh-workshop-istio-system.$CLUSTER_SUBDOMAIN
```
