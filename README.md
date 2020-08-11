# OpenShift Service Mesh Workshop
This content is sourced from the original content [here](https://github.com/RedHatGov/redhatgov.github.io/tree/docs/content/workshops/openshift_service_mesh).

The original content has been modified here to work with an OpenShift Homeroom deployment. Changes include
* Variable interpolation for user or cluster-specific variables in the lab guide content
* Usage of cluster-internal URLs for accessing or testing services with `curl`
* **Kiali** and **Jaeger** are built into the dashboard view for ease of use
    * Because these windows are loaded in HTML iframes, they cannot support OAuth authentication flows. We workaround this by using token-auth in Kiali and no auth in Jaeger.