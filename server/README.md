<img src="https://avatars3.githubusercontent.com/u/43526139?s=200&v=4" height="100" width="100" />

# Khulnasoft Server

## Overview
Server includes the following components:
* Console (Khulnasoft UI)
* Gateway
* Database (Optional)

## Deployment methods
* [Manifests and Khulnasoftctl](./kubernetes_and_openshift/manifests)
* [Helm](./kubernetes_and_openshift/helm)
* [Operator](./kubernetes_and_openshift/operator)
* [AWS CloudFormation ECS-EC2](./ecs/cloudformation/khulnasoft-ecs-ec2)
* [AWS CloudFormation ECS-Fargate](./ecs/cloudformation/khulnasoft-ecs-fargate)

## Supported platforms
* Kubernetes and Openshift
* AWS ECS
* Docker

### Note: 
* For OpenShift version 3.x use RBAC definition from ./kubernetes_and_openshift/manifests/khulnasoft_csp_002_RBAC/openshift_ocp3x 
* For OpenShift version 4.x use RBAC definition from ./kubernetes_and_openshift/manifests/khulnasoft_csp_002_RBAC/openshift 

## Suited for
* Khulnasoft Enterprise Self-Hosted edition

## References
Before you start using any of the deployment methods documented in this reposiory, Khulnasoft strongly recommends you to refer the following product documentation:
* [Deploy Server Components](https://docs.khulnasoft.com/docs/deploy-k8s-server-components) 
* [Kubernetes with Helm Charts](https://docs.khulnasoft.com/docs/kubernetes-with-helm)
* [Deploy Khulnasoft on Amazon Elastic Container Service (ECS)](https://docs.khulnasoft.com/docs/amazon-elastic-container-service-ecs#section-step-1-deploy-the-khulnasoft-server-gateway-and-database).