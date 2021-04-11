![Released Container Image](https://github.com/RedHatGov/service-mesh-workshop-dashboard/workflows/Released%20Container%20Image/badge.svg)

# OpenShift Service Mesh Workshop
This content has been designed to work with an OpenShift Homeroom deployment. Considerations include:
* Variable interpolation for user or cluster-specific variables in the lab guide content
* Usage of cluster-internal URLs for accessing or testing services with `curl`

The TL;DR of homeroom is that we build all these labs into a website, stuff that in a container, and deploy that container to the OpenShift cluster that the workshop attendees are using. This lets us show instructions side-by-side with the OpenShift webconsole and CLI terminal.

## Deploying this workshop - if you have RHPDS
We are working on getting this into a click-to-provision environment. It's not there yet, when it is this section will tell you how to order it.

## Deploying this workshop - in your own cluster
1. Complete [these steps](https://github.com/RedHatGov/service-mesh-workshop-code/tree/workshop-stable/deployment/workshop) **first**

2. Set a local `CLUSTER_SUBDOMAIN` environment variable
```bash
CLUSTER_SUBDOMAIN=<apps.openshift.com>
```
3. Create a project for the homeroom to live
```bash
oc new-project homeroom --display-name="Homeroom Workshops"
```
5. Grab the template to deploy a `workshop-spawner`. Note the `WORKSHOP_IMAGE` tag should be changed with the corresponding release you want to deploy.
```
oc process -f https://raw.githubusercontent.com/RedHatGov/workshop-spawner/develop/templates/hosted-workshop-production.json \
    -p SPAWNER_NAMESPACE=homeroom \
    -p CLUSTER_SUBDOMAIN=$CLUSTER_SUBDOMAIN \
    -p WORKSHOP_NAME=service-mesh-workshop \
    -p CONSOLE_IMAGE=quay.io/openshift/origin-console:4.5 \
    -p WORKSHOP_IMAGE=quay.io/redhatgov/service-mesh-workshop-dashboard:x.x.x \
| oc apply -n homeroom -f -
```

### Access info for the workshop
Your workshop attendees will need user accounts in the OpenShift cluster.

Now give this URL (or preferably a shortened version) to your workshop attendees:
>`echo https://service-mesh-workshop-homeroom.$CLUSTER_SUBDOMAIN`

#### Optional
Deploy a Username Distribution app for generating student IDs - this is especially handy for virtual workshops.
```bash
NUM_USERS=<number of workshop users>

oc process -f https://raw.githubusercontent.com/redhatgov/username-distribution/master/openshift/app-ephemeral.json \
    --param LAB_USER_PREFIX=user \
    --param LAB_USER_COUNT=$NUM_USERS \
    --param LAB_MODULE_URLS='https://service-mesh-workshop-homeroom.$CLUSTER_SUBDOMAIN;Workshop Dashboard' | oc apply -n homeroom -f -
```

Once this is deployed, give this URL to workshop attendees: 
```
echo https://username-distribution-homeroom.$CLUSTER_SUBDOMAIN
```

They'll need to enter a valid email address and the workshop password specified by the `LAB_USER_ACCESS_TOKEN` environment variable, for which the default is **redhatlabs**.

You can perform administrative actions by visiting `/admin` in the `username-distribution` app. You'll need to enter `admin` as a username and the value of the `LAB_ADMIN_PASS` environment variable, for which the default is **pleasechangethis**, as a password.

## Cleaning up after the workshop
As long as no one else is running a homeroom workshop in the same cluster, you can clean up with the following:
>`oc delete project homeroom`
