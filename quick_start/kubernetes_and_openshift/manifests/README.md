## Overview

The quick-start deployment can be used to deploy Khulnasoft Self-Hosted Enterprise on your Kubernetes cluster quickly and easily. It is suited for proofs-of-concept (POCs) and environments intended for instruction, development, and test but not for production environments.

For production usage, enterprise-grade deployments, advanced use cases, and deployment on other Kubernetes platforms, deploy Khulnasoft Enterprise with the required Khulnasoft components (such as server, enforcers, scanner, so on.) on your orchestration platform. For more information, refer to the Product documentation, [Deploy Khulnasoft Enterprise](https://docs.khulnasoft.com/docs/deployment-overview).

The quick-start deployment supports the following Kubernetes platforms:
* Kubernetes
* AKS (Microsoft Azure Kubernetes Service)
* EKS (Amazon Elastic Kubernetes Service)
* GKE (Google Kubernetes Engine)

Deployment commands shown in this file uses **kubectl** cli, however they can easily be replaced with the **oc** cli commands.

Before you start using the quick-start deployment method documented in this repository, Khulnasoft strongly recommends you to refer the product documentation, [Quick-Start Guide for Kubernetes](https://docs.khulnasoft.com/docs/quick-start-guide-for-kubernetes).

## Prerequisites
* Your Khulnasoft credentials: username and password
* Your Khulnasoft Enterprise License Token
* Access to the target Kubernetes cluster

## Configuration for Enforcers and storage

Through the quick-start deployment method, Khulnasoft Enforcer is deployed to provide runtime security for your Kubernetes workloads. In addition to Khulnasoft Enforcer, KubeEnforcer can also be deployed. If your Kubernetes cluster has shared storage, Khulnasoft can be deployed to use the same. If you use Minikube or your cluster does not have shared storage, Khulnasoft can be deployed using the host path for persistent storage. 

The following table shows different manifest yaml files that can be used to deploy Khulnasoft through quick-start method:

| File                                   | Purpose                                                                                             |
|----------------------------------------|---------------------------------------------------------------------------------------------------|
| khulnasoft-csp-quick-DaemonSet-hostPath.yaml | Deploy Khulnasoft Enterprise with the Khulnasoft Enforcer only, and use the host-path for storage             |
| khulnasoft-csp-quick-DaemonSet-storage.yaml  | Deploy Khulnasoft Enterprise with the Khulnasoft Enforcer only, and use default-storage                       |
| khulnasoft-csp-quick-default-storage.yaml    | Deploy Khulnasoft Enterprise with the Khulnasoft Enforcer and KubeEnforcer, and use default-storage           |
| khulnasoft-csp-quick-hostpath.yaml           | Deploy Khulnasoft Enterprise with the Khulnasoft Enforcer and KubeEnforcer, and use the host-path for storage |

## Pre-deployment

You can skip any step if you have already performed.

**Step 1. Create a namespace by name khulnasoft (if not already done).**

```SHELL
kubectl create namespace khulnasoft
```

**Step 2. Create a docker-registry secret (if not already done).**

```SHELL
kubectl create secret docker-registry khulnasoft-registry \
--docker-server=registry.khulnasoft.com \
--docker-username=<your-name> \
--docker-password=<your-pword> \
-n khulnasoft
```

## Deploy Khulnasoft Enterprise in your cluster

Deploy Khulnasoft Enterprise using the required yaml file mentioned in the current directory as per your use case. For example:

```SHELL
kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/quick_start/kubernetes_and_openshift/manifests/khulnasoft-csp-quick-DaemonSet-hostPath.yaml
```

For more information on selecting the yaml file that you need, refer to the [Configuration of Enforcers and storage](#configuration-of-enforcers-and-storage) section.

## Access Khulnasoft Enterprise console

**Step 1. Get the external IP of the console.**

```SHELL
kubectl get svc -n khulnasoft
```

**Step 2. Get the external IP of the console, if Khulnasoft Enterprise is deployed on Minikube.**

```SHELL
minikube tunnel
kubectl get svc -n khulnasoft
```

**Step 3. Access khulnasoft-web service from your browser using the url:**

```SHELL
http://<khulnasoft-web service>:<khulnasoft-web port>
```

## Troubleshooting to access Khulnasoft Enterprise

If you did not define a default load-balancer for your Kubernetes cluster, khulnasoft-web's public service IP status will remain frozen as "pending", after deploying through quick-start method. In this case, you can access Khulnasoft Enterprise using a client-side kubectl tunnel. 

If load-balancer is not defined, to access Khulnasoft Enterprise:

**Step 1. Use kubectl to get khulnasoft-web’s cluster IP.**

```SHELL
kubectl get pods -n khulnasoft
```

**Step 2. Use the kubectl port-forward command in a separate window to open the tunnel.**

```SHELL
kubectl port-forward -n khulnasoft khulnasoft-web <LOCAL_TUNNEL_PORT>:<KHULNASOFT_POD_CLUSTER_IP>
```

**Step 3. Access Khulnasoft Enterprise from your browser using the url:**

```SHELL
http://localhost:<LOCAL_TUNNEL_PORT>
```