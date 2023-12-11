<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Khulnasoft Scanner

## Overview
Khulnasoft scanner performs scanning of the following objects for security issues:
* Container images
* VMware Tanzu applications
* Serverless Functions

## Deployment methods
* [Manifests and Khulnasoftctl](./kubernetes_and_openshift/manifests/)
* [Helm](./kubernetes_and_openshift/helm/)
* [Operator](./kubernetes_and_openshift/operator/)
* [AWS CloudFormation on EC2 clusters](./ecs/cloudformation/khulnasoft-ecs-ec2)

## Suited for
* Khulnasoft Enterprise SaaS
* Khulnasoft Enterprise Self-Hosted

## Supported platforms
* Kubernetes and Openshift (SaaS and Self-Hosted)
* AWS ECS (Self-Hosted only)
* Docker (SaaS and Self-Hosted)

## References
Before you start using any method to deploy Khulnasoft scanner, Khulnasoft strongly recommends you to refer the Product documentation:
* [Deploy Scanner(s)](https://docs.khulnasoft.com/docs/deploy-k8s-scanners)
* [Kubernetes with Helm Charts](https://docs.khulnasoft.com/docs/kubernetes-with-helm#section-step-2-deploy-the-khulnasoft-server-database-gateway-and-scanner).