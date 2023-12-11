<img src="https://avatars3.githubusercontent.com/u/43526139?s=200&v=4" height="100" width="100" />

# Deploy Khulnasoft Cloud-Connector using manifests

## Overview
When deployed on local clusters, i.e., clusters on which Khulnasoft Platform is not deployed, the Khulnasoft Cloud
Connector establishes a secure connection to the Khulnasoft Platform console, giving Khulnasoft Platform remote
access to resources on the local clusters.

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
--docker-email=<your-email> \
-n khulnasoft
   ```
 
**Step 3. (Optional) Create a service account and RBAC for your deployment platform (if not already done).**

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/cloud_connector/kubernetes_and_openshift/manifests/001_cloud_connector_khulnasoft_sa.yaml
   ```   

## Deploy Khulnasoft Cloud-Connector using manifests
   
**Step 1. Create the secrets manually or download, edit, and apply the secrets.** Provide base64 username and password values for consoleI

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/cloud_connector/kubernetes_and_openshift/manifests/002_cloud_connector_secrets.yaml
   ```

**Step 2. Deploy directly or download, edit, and run the deployment configMaps**

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/cloud_connector/kubernetes_and_openshift/manifests/003_cloud_connector_configmap.yaml
   ```

**Step 3. Deploy Cloud-Connector Deployment** 

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/cloud_connector/kubernetes_and_openshift/manifests/004_cloud_connector_deployment.yaml
   ```
