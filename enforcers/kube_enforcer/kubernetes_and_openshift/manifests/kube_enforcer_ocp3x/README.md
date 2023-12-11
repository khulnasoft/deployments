# Deploy KubeEnforcer using manifests

## Overview

This repository shows the manifest yaml files required to deploy Khulnasoft KubeEnforcer on the following Kubernetes platforms:
* Kubernetes 
* OpenShift 
* Kubernetes engines: EKS, GKE, ICP, AKS, TKG, and TKGI

Starboard is deployed with the KubeEnforcer to increase the effectiveness of Kubernetes security.

Starboard assesses workload compliance throughout the lifecycle of the workloads. This enables the KubeEnforcer to:
* Re-evaluate workload compliance during workload runtime, taking any workload and policy changes into account
* Reflect the results of compliance evaluation in the Khulnasoft UI at all times, not only when workloads are created

Before you follow the deployment steps explained below, Khulnasoft strongly recommends you refer the product documentation, [Deploy Khulnasoft KubeEnforcer(s)](https://docs.khulnasoft.com/docs/deploy-k8s-khulnasoft-kubeenforcers) for detailed information.

## Specific OpenShift notes
The deployment commands shown below use the **kubectl** cli, however they can be easliy replaced with the **oc** cli commands, to work on all platforms including OpenShift.

## Prerequisites

- Your Khulnasoft credentials: username and password
- Access to Khulnasoft registry
- The target KubeEnforcer Group token
- Access to the target Khulnasoft gateway
- A PEM-encoded CA bundle to validate the KubeEnforcer certificate
- A PEM-encoded SSL cert to configure the KubeEnforcer

It is recommended that you complete the sizing and capacity assessment for the deployment. Refer to [Sizing Guide](https://docs.khulnasoft.com/docs/sizing-guide).

## Considerations

Consider the following options for deploying the KubeEnforcer:

- **PEM-encoded CA bundle and SSL certs**: Use the [gen_ke_certs.sh script](./gen_ke_certs.sh) to generate the required CA bundle, SSL certificates, and deploy the KubeEnforcer config. To generate CA bundle and SSL certificates manually, refer to the product documentation, [Configure mTLS](https://docs.khulnasoft.com/docs/configure-mtls).

- **Mutual Auth / Custom SSL certs**: Prepare the SSL cert for the domain you choose to configure for the Khulnasoft Server. You should modify the manifest deployment files with the mounts to the SSL secrets files.

- **Gateway**: To connect with an external Gateway in a multi-cluster deployment, update the **KHULNASOFT_GATEWAY_SECURE_ADDRESS** value with the Gateway endpoint address in the *001_kube_enforcer_config.yaml* manifest file.

## Pre-deployment

You can skip any step in this section, if you have already performed.

**Step 1. Create a namespace (or an OpenShift  project) by name khulnasoft.**

   ```SHELL
   kubectl create namespace khulnasoft
   ```
   Note: (Optional) Instead of Khulnasoft Namespace, You can also use your custom Namespace to deploy KubeEnforcer.

**Step 2. Create a docker-registry secret (if not already done).**

   ```shell
   kubectl create secret docker-registry khulnasoft-registry \
   --docker-server=registry.khulnasoft.com \
   --docker-username=<your-name> \
   --docker-password=<your-password> \
   --docker-email=<your-email> -n khulnasoft
   ```

## Deploy KubeEnforcer using manifests

**Step 1. Deploy the KubeEnforcer Config.**

   - **Option A (Automatic)**: Generate CA bundle (rootCA.crt), SSL certs (khulnasoft_ke.key, khulnasoft_ke.crt), and deploy the KubeEnforcer config.
        
      1. Generate certs for khulnasoft namespace.
        ```shell
        curl -s  https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/kube_enforcer/kubernetes_and_openshift/manifests/kube_enforcer/gen_ke_certs.sh | bash
        ```
      2. Generate certs for custom namespace, Replace the `<namespace name>` in the below command with the namespace where KE is going to be deployed, and run the command.
        ```shell
        curl https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/kube_enforcer/kubernetes_and_openshift/manifests/kube_enforcer/gen_ke_certs.sh | bash -s -- <namespace name>
        ```

   - **Option B (Manual)**: Perform the steps mentioned in the [Deploy the KubeEnforcer Config manually](#deploy-the-kubeenforcer-config-manually) section.

**Step 2.  Create token and SSL secrets.**

* Create the token secret.

  ```shell
  kubectl create secret generic khulnasoft-kube-enforcer-token --from-literal=token=<token_from_server_ui> -n khulnasoft
  ```

* Create the SSL cert secret using SSL certificates.
    
  ```shell
  kubectl create secret generic kube-enforcer-ssl --from-file khulnasoft_ke.key --from-file khulnasoft_ke.crt -n khulnasoft
  ```

                                        (or)

* Download, edit, and apply the secrets manifest file to create the token and SSL cert secrets.

  ```SHELL
  kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/kube_enforcer/kubernetes_and_openshift/manifests/kube_enforcer/002_kube_enforcer_secrets.yaml
  ```  

**Step 3. Deploy KubeEnforcer.**

```SHELL
kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/kube_enforcer/kubernetes_and_openshift/manifests/kube_enforcer/003_kube_enforcer_deploy.yaml
```

### Deploy the KubeEnforcer Config manually

Step 1. Download the manifest yaml file, *001_kube_enforcer_config.yaml*.

Step 2. Generate a CA bundle and SSL certs.

Step 3. Modify the config yaml file to include the PEM-encoded CA bundle (caBundle).

Step 4. Apply the modified manifest file config.

```shell
kubectl apply -f 001_kube_enforcer_config.yaml
```

## Automate KubeEnforcer deployment using Khulnasoftctl
Khulnasoftctl is the command-line utility to automate the deployment steps mentioned in the section, [Deploy KubeEnforcer using manifests](#deploy-kubeenforcer-using-manifests). Command shown in this section creates (downloads) manifests (yaml) files quickly and prepares them for the KubeEnforcer deployment.

### Command Syntax

```SHELL
khulnasoftctl download kube-enforcer [flags]
```

### Flags
You should pass the following deployment options through flags, as required.

#### Khulnasoftctl operation

Flag and parameter type              | Values                                                |
| ---------------------- | ------------------------------------------------------------ |
| -p or --platform, (string) (mandatory flag) | Orchestration platform to deploy Khulnasoft Enterprise on. you should pass one of the following as required: **kubernetes, aks, eks, gke, icp, openshift, tkg, tkgi**    |
| -v or --version
(string) (mandatory flag) | Major version of Khulnasoft Enterprise to deploy. For example: **2022.4** |
| -r or --registry (string) | Docker registry containing the Khulnasoft Enterprise product images, it defaults to **registry.khulnasoft.com** |
| --pull-policy (string) | The Docker image pull policy that should be used in deployment for the Khulnasoft product images, it defaults to **IfNotPresent** |
| --service-account (string) | Kubernetes service account name, it defaults to **khulnasoft-sa** |
| -n, --namespace (string) | Kubernetes namespace name, it defaults to **khulnasoft** |
| --output-dir (string) | Output directory for the manifests (YAML files), it defaults to **khulnasoft-deploy**, the directory khulnasoftctl was launched in |

#### KubeEnforcer configuration

Flag and type              | Values                                                |
| ---------------------- | ------------------------------------------------------------ |
| --gateway-url (string) | Khulnasoft Gateway URL (IP, DNS, or service name) and port, it defaults to **khulnasoft-gateway:8443**|
| --token (string) | Deployment token for the KubeEnforcer group, it does not have a default value|
| --ke-no-ssl (Boolean) | If specified as **true**, the SSL cert for the KubeEnforcer will not be generated. It defaults to **false**|

The **--gateway-url** flag identifies an existing Khulnasoft Gateway used to connect the KubeEnforcer. This flag is not used to configure a new Gateway, as in *khulnasoftctl download all* or *khulnasoftctl download server*.

After the manifests are created, follow the instructions that appear on the console to perform the actual deployment.

### Usage example 

```SHELL
khulnasoftctl download kube-enforcer --platform gke --version 2022.4 \
--token <KUBE_ENFORCER_GROUP_TOKEN> \
--gateway-url 221.252.82.95:8443 --output-dir khulnasoft-kube-enforcer-files
```
