![Released Container Image](https://github.com/RedHatGov/service-mesh-workshop-dashboard/workflows/Released%20Container%20Image/badge.svg)

# OpenShift Service Mesh Workshop
This content has been designed to work with an OpenShift Homeroom deployment. Considerations include:
* Variable interpolation for user or cluster-specific variables in the lab guide content
* Usage of cluster-internal URLs for accessing or testing services with `curl`

The TL;DR of homeroom is that we build all these labs into a website, stuff that in a container, and deploy that container to the OpenShift cluster that the workshop attendees are using. This lets us show instructions side-by-side with the OpenShift webconsole and CLI terminal.

## How To Provision

### Order from RHPDS

TBD

### AgnosticD Deployment

Please see [agnosticd repo](https://github.com/redhat-cop/agnosticd) if you need a primer.

1. Order an OpenShift 4.x Cluster on [RHPDS](https://rhpds.redhat.com).

2. Set environment variables (substitute your own values)

```bash
export TARGET_HOST=changeme     # example: bastion.b454.sandbox1682.opentlc.com
export OCP_USERNAME=changeme
export WORKLOAD="ocp4_workload_servicemesh_workshop"
export GUID=example     # example: b454
```

3. Run AgnosticD  (use my fork: https://github.com/theckang/agnosticd/tree/servicemesh-workshop)

```bash
ansible-playbook -i ${TARGET_HOST}, ./configs/ocp-workloads/ocp-workload.yml \
    -e"ansible_ssh_private_key_file=$HOME/.ssh/id_rsa" \
    -e"ansible_user=${OCP_USERNAME}" \
    -e"ocp_username=${OCP_USERNAME}" \
    -e"ocp_workload=${WORKLOAD}" \
    -e"silent=False" \
    -e"guid=${GUID}" \
    -e"ACTION=create"
```

## Access Info
> Make sure you provisioned the workshop using RHPDS or ran the AgnosticD role on the cluster.

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

## Clean Up
Delete the RHPDS cluster once you are done running the workshop
