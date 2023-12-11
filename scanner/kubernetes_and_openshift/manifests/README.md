# Deploy Khulnasoft Scanner using manifests

## Overview

This repository shows the manifest yaml files required to deploy Khulnasoft Scanner on the following Kubernetes platforms:
* Kubernetes
* OpenShift
* Kubernetes engines: EKS, GKE, ICP, AKS, TKG, and TKGI

Before you follow the deployment steps explained below, Khulnasoft strongly recommends you refer to the product documentation, [Deploy Khulnasoft Scanner](https://docs.khulnasoft.com/docs/deploy-k8s-scanners) for detailed information.

## Specific OpenShift notes
The deployment commands shown below use the **kubectl** cli, you can also deploy using the **oc** cli commands, to work on all platforms including OpenShift.

## Prerequisites

- Your Khulnasoft credentials: username and password
- *Scanner* role permissions to authenicate over the Khulnasoft server
- Update the following secrets in base64 encoding in the [002_scanner_secrets.yaml](./002_scanner_secrets.yaml) file:
  - KHULNASOFT_SCANNER_USERNAME
  - KHULNASOFT_SCANNER_PASSWORD
- Update the following data in [003_scanner_configmap.yaml](./003_scanner_configmap.yaml) file:
  - KHULNASOFT_SERVER (Khulnasoft Server URL or IP followed by the HTTPS port number)

## Deployment considerations

Consider the following options for deploying Khulnasoft Scanner:

- It is recommended to deploy scanners close to your registry to decrease the network latency and improve scanning performance.

- **Mutual Auth / Custom SSL certs**: 
  - **To use a globally trusted public CA:** You do not have to modify anything on the scanner side, since the scanner container has all the public CAs pre-installed within
  
  - **To use private CA:** Prepare the SSL cert for the domain you choose to configure for the Khulnasoft Server. You should modify the manifest deployment files with the mounts to the SSL secrets files at **/etc/ssl/certs**
  
  - **To use Khulnasoft generated certs:** Populate root CA to the scanner deployment. To get this cert, connect to khulnasoft instance and copy it from **/opt/khulnasoft/cert.pem**
  
  - ***(Optional)* mTLS communication between scanner and the offline CyberCenter:**  If you deploy additional scanners for the scanning operation, the offline CyberCenter communicates with these scanners. To configure mTLS (mutual TLS) communication between scanner and the offline CyberCenter, refer to the product documentation, [Configure mTLS between the Offline CyberCenter and Scanner](https://docs.khulnasoft.com/docs/configure-mtls-between-the-offline-cybercenter-and-scanner)

## Pre-deployment

You can skip any of the steps if you have already performed.

**Step 1. Create a namespace (or an OpenShift  project) by name khulnasoft (if not already done).**

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

**Step 3. Create a service account (if not already done).**

```SHELL
kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/scanner/kubernetes_and_openshift/manifests/001_scanner_serviceAccount.yaml
```

## Deploy Scanner using manifests

**Step 1. Create secrets manually or download, edit, and apply the secrets.**

```SHELL
kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/scanner/kubernetes_and_openshift/manifests/002_scanner_secrets.yaml
```

**Step 2. Create Configmap manually or download, edit, and apply the configmap by adding `KHULNASOFT_SERVER`.**

```SHELL
kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/scanner/kubernetes_and_openshift/manifests/003_scanner_configmap.yaml
```

**Step 2. Deploy Khulnasoft Scanner.**

```SHELL
kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/scanner/kubernetes_and_openshift/manifests/004_scanner_deploy.yaml
```

### (Optional) External storage for image scans data (PVC)
The scanner doesn't need any persistent storage to work since scanned data is automatically cleared after every scan, but in case you require to use an external volume to host data scans, you can uncomment these sections in the deployment file before running the kubectl commands:
* PVC object
* Volume block
* VolumeMount block

## Automate Scanner deployment using Khulnasoftctl

Khulnasoftctl is the command-line utility to automate the deployment steps mentioned in the section, [Deploy Scanner using manifests](#deploy-scanner-using-manifests). Command shown in this section creates (downloads) manifests (yaml) files quickly and prepares them for the Scanner deployment.

### Command Syntax

```SHELL
khulnasoftctl download scanner [flags]
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

#### Khulnasoft Scanner configuration

Flag and type              | Values                                                |
| ---------------------- | ------------------------------------------------------------ |
| --server-url (string) | Khulnasoft Server URL (IP, domain, or service name) followed by an HTTPS port. It defaults to **khulnasoft-web:443**|
| --username (string) | Username of an Khulnasoft user with the Scanner role|
| --password (string) | Password for the username with the Scanner role|

After the manifests are created, follow the instructions that appear on the console to perform the actual deployment.

### Usage example 

```SHELL
khulnasoftctl download scanner --platform gke --version 2022.4 \
--server-url 215.150.97.228:443 --output-dir khulnasoft-scan-files
```