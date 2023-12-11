
# Deploy Khulnasoft Windows Enforcer using manifests
## Overview

This repository shows the manifest yaml files required to deploy Khulnasoft Widnows Enforcer on the following Kubernetes platforms:
* AKS 

Before you follow the deployment steps explained below, Khulnasoft strongly recommends you refer the product documentation, [Deploy Khulnasoft Enforcer(s)](https://docs.khulnasoft.com/docs/deploy-k8s-khulnasoft-enforcers) for detailed information.

## Prerequisites for manifest deployment

- Your Khulnasoft credentials: username and password
- Access to Khulnasoft registry to pull images
- The target Enforcer Group token 
- Access to the target Khulnasoft gateway 

It is recommended that you complete the sizing and capacity assessment for the deployment. Refer to [Sizing Guide](https://docs.khulnasoft.com/docs/sizing-guide).

## Considerations

You may consider the following options for deploying the Khulnasoft Enforcer:

- Gateway
  
  - To connect with an external Gateway, update the **KHULNASOFT_SERVER** value with the gateway endpoint address in the *002_khulnasoft_windows_enforcer_configMaps.yaml* configMap manifest file.

## Supported platforms
| < PLATFORM >              | Description                                                  |
| ---------------------- | ------------------------------------------------------------ |
| aks | Microsoft Azure Kubernetes Service (AKS)    |


## Pre-deployment
You can skip any of the steps if you have already performed.

**Step 1. Create a namespace (or an OpenShift project) by name khulnasoft (if not already done).**

   ```SHELL
   kubectl create namespace khulnasoft
   ```

**Step 2. Create a docker-registry secret (if not already done).**

```SHELL
kubectl create secret docker-registry khulnasoft-registry \
--docker-server=registry.khulnasoft.com \
--docker-username=<your-name> \
--docker-password=<your-pword> \
--docker-email=<your-email> \
-n khulnasoft
   ```

**Step 3. Create a service account and RBAC for your deployment platform (if not already done).** Replace the platform name from [Supported platforms](#supported-platforms).

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/windows_enforcer/kubernetes/001_khulnasoft_windows_enforcer_rbac/aks/khulnasoft_sa.yaml
   ```

## Deploy Khulnasoft Enforcer using manifests

**Step 1. Create secrets for deployment**

   * Create the token secret that authenticates the Khulnasoft Windows Enforcer over the Khulnasoft Server.

      ```SHELL
      kubectl create secret generic windows-enforcer-token --from-literal=token=<token_from_server_ui> -n khulnasoft
      ```

                                        (or)

     * Download, edit, and apply the secrets.

      ```SHELL
      kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/windows_enforcer/kubernetes/003_khulnasoft_windows_enforcer_secrets.yaml
      ```    

**Step 2. Deploy directly or download, edit, and apply ConfigMap as required.**

```SHELL
kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/windows_enforcer/kubernetes/002_khulnasoft_windows_enforcer_configMap.yaml
```

**Step 3. Deploy Khulnasoft Enforcer as daemonset.**

```SHELL
kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/windows_enforcer/kubernetes/004_khulnasoft_windows_enforcer_daemonset.yaml
```
