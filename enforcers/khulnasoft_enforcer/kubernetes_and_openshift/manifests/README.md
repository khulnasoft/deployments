
# Deploy Khulnasoft Enforcer using manifests
## Overview

This repository shows the manifest yaml files required to deploy Khulnasoft Enforcer on the following Kubernetes platforms:
* Kubernetes 
* OpenShift 
* Kubernetes engines: EKS, GKE, ICP, AKS, TKG, and TKGI

Before you follow the deployment steps explained below, Khulnasoft strongly recommends you refer the product documentation, [Deploy Khulnasoft Enforcer(s)](https://docs.khulnasoft.com/docs/deploy-k8s-khulnasoft-enforcers) for detailed information.

### Specific OpenShift notes
The deployment commands shown below, use the **kubectl** cli, however they can be easliy replaced with the **oc** cli commands, to work on all platforms including OpenShift.

## Prerequisites for manifest deployment

- Your Khulnasoft credentials: username and password
- Access to Khulnasoft registry to pull images
- The target Enforcer Group token 
- Access to the target Khulnasoft gateway 

It is recommended that you complete the sizing and capacity assessment for the deployment. Refer to [Sizing Guide](https://docs.khulnasoft.com/docs/sizing-guide).

## Considerations

You may consider the following options for deploying the Khulnasoft Enforcer:

- Mutual Auth / Custom SSL certs

  - Prepare the SSL cert for your Khulnasoft Server domain to use your CA authority. You should modify the manifest deployment files with the mounts to the SSL secrets files. 

- Gateway
  
  - To connect with an exteranl Gateway, update the **KHULNASOFT_SERVER** value with the gateway endpoint address in the *002_khulnasoft_enforcer_configMaps.yaml* configMap manifest file.

## Supported platforms
| < PLATFORM >              | Description                                                  |
| ---------------------- | ------------------------------------------------------------ |
| aks | Microsoft Azure Kubernetes Service (AKS)    |
| eks | Amazon Elastic Kubernetes Service (EKS) |
| gke | Google Kubernetes Engine (GKE) |
| ibm | IBM Cloud Private (ICP) |
| k3s | fully CNCF certified Kubernetes |
| native_k8s | Kubernetes |
| openshift | OpenShift (Red Hat) |
| rancher | Rancher / Kubernetes |
| tkg | VMware Tanzu Kubernetes Grid (TKG) |
| tkgi | VMware Tanzu Kubernetes Grid Integrated Edition (TKGI) |

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
   kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/khulnasoft_enforcer/kubernetes_and_openshift/manifests/001_khulnasoft_enforcer_rbac/< PLATFORM >/khulnasoft_sa.yaml
   ```

## Deploy Khulnasoft Enforcer using manifests

**Step 1. Create secrets for deployment**

   * Create the token secret that authenticates the Khulnasoft Enforcer over the Khulnasoft Server.

      ```SHELL
      kubectl create secret generic enforcer-token --from-literal=token=<token_from_server_ui> -n khulnasoft
      ```

                                        (or)

     * Download, edit, and apply the secrets.

      ```SHELL
      kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/khulnasoft_enforcer/kubernetes_and_openshift/manifests/003_khulnasoft_enforcer_secrets.yaml
      ```    

**Step 2. Deploy directly or download, edit, and apply ConfigMap as required.**

```SHELL
kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/khulnasoft_enforcer/kubernetes_and_openshift/manifests/002_khulnasoft_enforcer_configMap.yaml
```

**Step 3. Deploy Khulnasoft Enforcer as daemonset.**

```SHELL
kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/khulnasoft_enforcer/kubernetes_and_openshift/manifests/004_khulnasoft_enforcer_daemonset.yaml
```

#### For eks-bottlerocket deployment edit 004_khulnasoft_enforcer_daemonset.yaml as follows
```yaml 
securityContext:
   privileged: true
   seLinuxOptions:
      user: system_u
      role: system_r
      type: super_t
      level: s0
```

## Automate Khulnasoft Enforcer deployment using Khulnasoftctl
Khulnasoftctl is the command-line utility to automate the deployment steps mentioned in the section, [Deploy Khulnasoft Enforcer using Manifests](#deploy-khulnasoft-enforcer-using-manifests). Command shown in this section creates (downloads) manifests (yaml) files quickly and prepares them for the Khulnasoft Enforcer deployment.

### Command Syntax

```SHELL
khulnasoftctl download enforcer [flags]
```

### Flags
You should pass the following deployment options through flags, as required.

#### Khulnasoftctl operation

Flag and parameter type              | Values                                                |
| ---------------------- | ------------------------------------------------------------ |
| -p or --platform, (string) (mandatory flag) | Orchestration platform to deploy Khulnasoft Enterprise on. you should pass one of the following as required: **kubernetes, aks, eks, gke, icp, openshift, tkg, tkgi**    |
| * -v or --version
(string) (mandatory flag) | Major version of Khulnasoft Enterprise to deploy. For example: **2022.4** |
| -r or --registry (string) | Docker registry containing the Khulnasoft Enterprise product images, it defaults to **registry.khulnasoft.com** |
| --pull-policy (string) | The Docker image pull policy that should be used in deployment for the Khulnasoft product images, it defaults to **IfNotPresent** |
| --service-account (string) | Kubernetes service account name, it defaults to **khulnasoft-sa** |
| -n, --namespace (string) | Kubernetes namespace name, it defaults to **khulnasoft** |
| --output-dir (string) | Output directory for the manifests (YAML files), it defaults to **khulnasoft-deploy**, the directory khulnasoftctl was launched in |

#### Khulnasoft Enforcer configuration

Flag and type              | Values                                                |
| ---------------------- | ------------------------------------------------------------ |
| --gateway-url (string) | Khulnasoft Gateway URL (IP, DNS, or service name) and port, it defaults to **khulnasoft-gateway:8443**|
| --token (string) | Deployment token for the Khulnasoft Enforcer group, it defaults to **enforcer-token**|

The **--gateway-url** flag identifies an existing Khulnasoft Gateway used to connect the Khulnasoft Enforcer. This flag is not used to configure a new Gateway, as in *khulnasoftctl download all* or *khulnasoftctl download server*.

After the manifests are created, follow the instructions that appear on the console to perform the actual deployment.

### Usage example 

```SHELL
khulnasoftctl download enforcer --platform gke --version 2022.4
```