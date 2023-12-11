<img src="https://avatars3.githubusercontent.com/u/43526139?s=200&v=4" height="100" width="100" />

# Khulnasoft KubeEnforcer

## Overview

The KubeEnforcer runs as a deployment and provides admission runtime security for Kubernetes workloads and infrastructure.

A single KubeEnforcer can be deployed on each Kubernetes cluster and uses native Kubernetes Admission Controller APIs to perform its functions, without the need for an Khulnasoft Enforcer:

* [MutatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#mutatingadmissionwebhook): seamlessly applies security controls for deployments
* [ValidatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#validatingadmissionwebhook) enforces Assurance Policies on newly deployed workloads

## Deployment methods
* [Manifests and Khulnasoftctl](./kubernetes_and_openshift/manifests)
* [Helm](./kubernetes_and_openshift/helm)
* [Operator](./kubernetes_and_openshift/operator)

## Supported platforms
* Kubernetes and Openshift

KubeEnforcers are supported on Linux platforms (with exception of VMware Tanzu TKGI).

## Suited for
* Khulnasoft Enterprise SaaS
* Khulnasoft Enterprise Self-Hosted

## References

Before you start using any of the deployment methods documented in this reposiory, Khulnasoft strongly recommends you to refer the following product documentation:
* [Deploy Kube Enforcer(s)](https://docs.khulnasoft.com/docs/deploy-k8s-khulnasoft-kubeenforcers).
* [Enforcers Overview](https://docs.khulnasoft.com/docs/enforcers-overview#section-kube-enforcers).