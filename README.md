![Released Container Image](https://github.com/RedHatGov/service-mesh-workshop-dashboard/workflows/Released%20Container%20Image/badge.svg)

# OpenShift Service Mesh Workshop
This content has been designed to work with an OpenShift Homeroom deployment. Considerations include:
* Variable interpolation for user or cluster-specific variables in the lab guide content
* Usage of cluster-internal URLs for accessing or testing services with `curl`

The TL;DR of homeroom is that we build all these labs into a website, stuff that in a container, and deploy that container to the OpenShift cluster that the workshop attendees are using. This lets us show instructions side-by-side with the OpenShift webconsole and CLI terminal.

## How To Provision

### Order from RHPDS

In the catalog, navigate to [All Services] -> [Openshift Workshop] -> [OpenShift Service Mesh 2 Workshop]

Make sure to set `Number of Users` to the number of expected participants in your workshop.

[If you are an admin, you can find the workshop guide here](https://docs.google.com/document/d/1A9pXa_sCto0ZkfeTV07eyf0vNeyk10W-o3-0TrIGBqk/edit#)


### Access Info
> Make sure you provisioned the workshop using RHPDS or [ran the AgnosticD role](./README-AgnosticD.md) on the cluster.

Give this URL to workshop attendees: 
```
echo https://username-distribution-homeroom.$CLUSTER_SUBDOMAIN
```

They'll need to enter a valid email address and the workshop password specified by the `LAB_USER_ACCESS_TOKEN` environment variable, for which the default is **redhatlabs**.  Once logged in, they'll be given a user account and a link to the workshop.

You can perform administrative actions by visiting `/admin` in the `username-distribution` app. You'll need to enter `admin` as a username and the value of the `LAB_ADMIN_PASS` environment variable, for which the default is **pleasechangethis**, as a password.

For direct access to the workshop, you can navigate to:
```
echo https://service-mesh-workshop-homeroom.$CLUSTER_SUBDOMAIN
```

### Clean Up
Delete the RHPDS cluster once you are done running the workshop

