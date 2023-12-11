# Deploy VM Enforcer using RPM Package

## Overview
Red Hat Linux and its derivatives such as CentOS and Fedora use RPM Package Manager to manage and install software. RPM also refers to the `rpm`, `yum` and `dnf` commands and `.rpm` file format. 

You can use RPM package to deploy a VM Enforcer on one or more VMs (hosts).

## Prerequisites
Following packages are required for installing VM Enforcer `.rpm` package:
* wget
* tar
* jq
* runc

## Deploy VM Enforcer

**Step 1. Download the RPM package for your architecture, using an authorized username and password.**


   * **x86_64/amd64:**
  
        ```shell
       wget -v https://download.khulnasoft.com/host-enforcer/<release-number>/khulnasoft-vm-enforcer-<build-number>.x86_64.rpm \
        --user=<Username> \
        --ask-password
       ```
   * **arm64:**
  
     ```shell
     wget -v https://download.khulnasoft.com/host-enforcer/<release-number>/khulnasoft-vm-enforcer-<build-number>.aarch64.rpm \
      --user=<Username> \
      --ask-password
     ```

Make sure to replace the `<release-number>` and `<build-number>` with the relevant versions, check khulnasoft release page [khulnasoft update releases](https://docs.khulnasoft.com/docs/update-releases).

**Step 2. Copy the downloaded RPM package onto the target VM(s).**


**Step 3. Write the `khulnasoftvmenforcer.json` configuration file**

```shell
sudo mkdir -p /etc/conf/
sudo touch /etc/conf/khulnasoftvmenforcer.json
```

**Step 4. Run the following command with the relevant values for:**

   * `GATEWAY_HOSTNAME` and `PORT`: Khulnasoft Gateway host/IP address and port
   * `TOKEN_VALUE`: Enforcer group token
   * `KHULNASOFT_TLS_VERIFY_VALUE`: false\true, Set up the enforcer with tls-verify. This is optional, but it is **MANDATORY** for khulnasoft **cloud** users with value `true`.
   * If `KHULNASOFT_TLS_VERIFY_VALUE` value is `true` below values are **MANDATORY** :
   * `ROOT_CA_PATH`: path to root CA certififate (Incase of self-signed certificate otherwise `ROOT_CA_PATH` is **OPTIONAL** )
   [NOTE]: ROOT_CA_PATH certificate value must be same as that is used to generate Gateway certificates
   * `PUBLIC_KEY_PATH`: path to Client public certififate
   * `PRIVATE_KEY_PATH`: path to Client private key
   
   ```shell
   sudo tee /etc/conf/khulnasoftvmenforcer.json << EOF
   {
       "KHULNASOFT_GATEWAY": "{GATEWAY_HOSTNAME}:{PORT}",
       "KHULNASOFT_TOKEN": "{TOKEN_VALUE}",
       "KHULNASOFT_TLS_VERIFY": {KHULNASOFT_TLS_VERIFY_VALUE},
       "KHULNASOFT_ROOT_CA": "{ROOT_CA_PATH}",
       "KHULNASOFT_PUBLIC_KEY": "{PUBLIC_KEY_PATH}",
       "KHULNASOFT_PRIVATE_KEY": "{PRIVATE_KEY_PATH}"       
   }
   EOF
   ```

**Step 5. Deploy the RPM**

```shell
sudo rpm -ivh /path/to/khulnasoft-vm-enforcer-{version}.{arch}.rpm
```

## Upgrade

To upgrade the VM Enforcer using the RPM package:

1. Download the (updated) RPM package. Refer to step 1 in the [Deploy VM Enforcer](#deploy-vm-enforcer) section.
2. Upgrade the VM Enforcer using the following command:

```shell
sudo rpm -U /path/to/khulnasoft-vm-enforcer-<version>.<arch>.rpm
```

## Troubleshooting

### Check the logs

Check the VM Enforcer application logs.

```shell
cat /opt/khulnasoft/tmp/khulnasoft.log
```

### Check the Journal

1. Check the service status.
   
```shell
sudo systemctl status khulnasoft-enforcer
```

2. Check the journal logs.

If the service status is inactive or shows any errors, you can check the journalctl logs for more details:

```shell
sudo journalctl -u khulnasoft-enforcer.service
```
   
## Uninstall
To uninstall the VM Enforcer `rpm` package:

```shell
sudo rpm -e khulnasoft-vm-enforcer
```

## Build an RPM package (optional)

To Build an RPM package for VM-Enforcer:
1. Update the RPM scripts as required.
2. Update the RPM version in `nfpm.yaml`.
3. Upload the VM-Enforcer archive to `archives` folder.
4. Create environment variables of `RPM_ARCH` and `RPM_VERSION`.

```shell
export RPM_ARCH=x86_64 #change to arm64 for arm based systems
export RPM_VERSION=2022.4 #mention version for VM Enforcer
```

5. Download NFPM (RPM Package Creator).

```shell
    echo '[goreleaser]
    name=GoReleaser
    baseurl=https://repo.goreleaser.com/yum/
    enabled=1
    gpgcheck=0' | sudo tee /etc/yum.repos.d/goreleaser.repo
    sudo yum install nfpm

```

6. Build the RPM.

```shell
mkdir -p pkg
nfpm pkg --packager rpm --target ./pkg/
```