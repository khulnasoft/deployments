<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Khulnasoft Enforcer 

## Overview

Khulnasoft Enforcers provide full runtime protection and other functionality for containers and selected host-related functionality.

In Kubernetes, the enforcer runs as a DaemonSet deployment for workload runtime security, blocking unauthorized deployments, monitoring and restricting runtime activities and generating audit events.

## Deployment methods
* [Manifests and Khulnasoftctl](./kubernetes_and_openshift/manifests)
* [Helm](./kubernetes_and_openshift/helm)
* [Operator](./kubernetes_and_openshift/operator)
* [AWS CloudFormation ECS-EC2](./ecs/cloudformation/khulnasoft-ecs-c2)

## Suited for
* Khulnasoft Enterprise SaaS
* Khulnasoft Enterprise Self-Hosted

## Supported platforms
* Kubernetes and Openshift (SaaS and Self-Hosted)
* AWS ECS (Self-Hosted only)
* Docker (SaaS and Self-Hosted)

### Note:
* For OpenShift version 3.x use RBAC definition from ./khulnasoft_enforcer/kubernetes_and_openshift/manifests/001_khulnasoft_enforcer_rbac/openshift_ocp3x
* For OpenShift version 4.x use RBAC definition from ./khulnasoft_enforcer/kubernetes_and_openshift/manifests/001_khulnasoft_enforcer_rbac/openshift


## References
Before you start using any of the deployment methods documented in this reposiory, Khulnasoft strongly recommends you to refer the following product documentation:
* [Deploy Khulnasoft Enforcer(s)](https://docs.khulnasoft.com/docs/deploy-k8s-khulnasoft-enforcers)
* [Kubernetes with Helm Charts](https://docs.khulnasoft.com/docs/kubernetes-with-helm#section-step-4-deploy-the-khulnasoft-enforcer)
* [Deploy Khulnasoft on Amazon Elastic Container Service (ECS)](https://docs.khulnasoft.com/docs/amazon-elastic-container-service-ecs#section-step-2-deploy-khulnasoft-enforcers).
* [Enforcers Overview](https://docs.khulnasoft.com/docs/enforcers-overview#section-khulnasoft-enforcers) and [Khulnasoft Enforcer](https://docs.khulnasoft.com/docs/khulnasoft-enforcer).