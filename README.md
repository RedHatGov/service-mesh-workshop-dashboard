# OpenShift Service Mesh Workshop
This content is sourced from the original content [here](https://github.com/RedHatGov/redhatgov.github.io/tree/docs/content/workshops/openshift_service_mesh).

The original content has been modified here to work with an OpenShift Homeroom deployment. Changes include
* Variable interpolation for user or cluster-specific variables in the lab guide content
* Usage of cluster-internal URLs for accessing or testing services with `curl`
* **Kiali** and **Jaeger** are built into the dashboard view for ease of use
    * Because these windows are loaded in HTML iframes, they cannot support OAuth authentication flows. We workaround this by using token-auth in Kiali and no auth in Jaeger.  

## Deploying this workshop
1. Complete [these steps](https://github.com/RedHatGov/openshift-microservices/tree/workshop-stable/deployment/workshop) **first**
2. Adjust **Kiali** and **Jaeger** as indicated above
3. Set a local `CLUSTER_SUBDOMAIN` environment variable
4. Grab my template to deploy a `workshop-spawner`. Note that the `CUSTOM_TAB_*` variables take the form `<tabLabel>=<url>` 
```
CLUSTER_SUBDOMAIN=<apps.openshift.com>

oc process -f https://raw.githubusercontent.com/andykrohg/workshop-spawner/custom-tabs/templates/hosted-workshop-production.json \
    -p SPAWNER_NAMESPACE=istio-system \
    -p CLUSTER_SUBDOMAIN=$CLUSTER_SUBDOMAIN \
    -p WORKSHOP_NAME=service-mesh-workshop \
    -p WORKSHOP_IMAGE=quay.io/akrohg/service-mesh-workshop-dashboard:latest \
    -p CUSTOM_TAB_1=Kiali=https://kiali-istio-system.$CLUSTER_SUBDOMAIN \
    -p CUSTOM_TAB_2=Jaeger=https://jaeger-istio-system.$CLUSTER_SUBDOMAIN \
| oc apply -f -
```