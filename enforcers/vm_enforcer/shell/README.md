# Deploy VM Enforcer using Shell Scripts


## Overview

You can deploy VM Enforcer on your execution VM using the shell script provided by Khulnasoft. This procedure is supported for the Linux platform only.

## Prerequisites for RHEL8

1) Selinux
2) Selinux Policy Devel 
    `sudo yum install setools-console selinux-policy-devel`

## Prerequisites for Fedora CoreOS

1) Selinux
2) Selinux Policy Devel
3) bc 
    `sudo rpm-ostree install bc setools-console selinux-policy-devel`

## Deployment modes

Deployment of VM Enforcer is supported by two modes as explained below.
### Online mode

Deploying VM Enforcer in the online mode can download the archive file from khulnasoft and stores in the current directory automatically. Add the following flags in the `Install_vme.sh` script to deploy VM Enforcer.

**Execute the following command to run and install VM Enforcer**
Switch to the root user and run:
```shell
  curl -s https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/vm_enforcer/shell/install_vme.sh | ENFORCER_VERSION=<value> GATEWAY_ENDPOINT=<value> TOKEN=<value> KHULNASOFT_USERNAME=<value> KHULNASOFT_PWD=<value> bash
```


**Variables description**

```shell

  ENFORCER_VERSION  string         Khulnasoft Enforcer version
  GATEWAY_ENDPOINT  string         Khulnasoft Gateway address
  TOKEN             string         Khulnasoft Enforcer token

  DOWNLOAD_MODE     bool           download artifacts from khulnasoft default value = true
  KHULNASOFT_USERNAME     string         Khulnasoft username
  KHULNASOFT_PWD          string         Khulnasoft password

  KHULNASOFT_TLS_VERIFY (Optional):

  KHULNASOFT_TLS_VERIFY   bool           default value = false
  -tls, --khulnasoft-tls-verify khulnasoft_tls_verify
  --rootca-file                    path to root CA certififate (Incase of self-signed certificate otherwise --rootca-file is optional )
  NOTE: --rootca-file certificate value must be same as that is used to generate Gateway certificates
  --publiccert-file                path to Client public certififate
  --privatekey-file                path to Client private key  

  KHULNASOFT_MEMORY_LIMIT (Optional):
  KHULNASOFT_MEMORY_LIMIT  numeric       enforcer memory limit in Gb. default value = 2.6

  KHULNASOFT_CPU_LIMIT (Optional):
  KHULNASOFT_CPU_LIMIT     numeric       enforcer cpu limit in cores. default value = 2
 
```

### Offline mode

**Prerequisite:** You should download archive file, khulnasoft templates and khulnasoft config from khulnasoft repository manually and store in the current directory.

**Step 1: Download Archive**

```shell
  wget https://download.khulnasoft.com/host-enforcer/<release-number>khulnasoft-host-enforcer.<build-number>.tar --user=<Username> --ask-password
```

Make sure to replace the `<release-number>` and `<build-number>` with the relevant versions, check khulnasoft release page [khulnasoft update releases](https://docs.khulnasoft.com/docs/update-releases).

**Step 2: Download khulnasoft templates and config files**

```shell
  curl -s -o khulnasoft-enforcer.template.service https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/vm_enforcer/templates/khulnasoft-enforcer.template.service
  curl -s -o khulnasoft-enforcer.template.old.service https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/vm_enforcer/templates/khulnasoft-enforcer.template.old.service
  curl -s -o run.template.sh https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/vm_enforcer/templates/run.template.sh
  curl -s -o khulnasoft-enforcer-runc-config.json https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/vm_enforcer/templates/khulnasoft-enforcer-runc-config.json
  curl -s -o khulnasoft-enforcer-v1.0.0-rc2-runc-config.json https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/vm_enforcer/templates/khulnasoft-enforcer-v1.0.0-rc2-runc-config.json
```

**Step 3: Download and Deploy VM Enforcer**

**Download Archive**

```shell
  curl -s -o install_vme.sh https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/vm_enforcer/shell/install_vme.sh
  chmod +x ./install_vme.sh
```

**Deploy VM Enforcer**

Add the following flags in the `Install_vme.sh` script to deploy VM Enforcer in the offline mode.

```shell
  sudo ./install_vme.sh [flags]

  Flags:
  -v, --version  string         Khulnasoft Enforcer version
  -g, --gateway  string         Khulnasoft Gateway address
  -t, --token    string         Khulnasoft Enforcer token
  -d, --download bool           Download Khulnasoft Host Enforcer ( default value = true )

  TLS verify Flag (Optional):
  -tls, --khulnasoft-tls-verify khulnasoft_tls_verify
  --rootca-file                 path to root CA certififate (Incase of self-signed certificate otherwise --rootca-file is optional )
  NOTE: --rootca-file certificate value must be same as that is used to generate Gateway certificates
  --publiccert-file             path to Client public certififate
  --privatekey-file             path to Client private key   
  CPU & memory limits (Optional):
  --memory-limit                enforcer memory limit in Gb ( default value = 2.6 )
  --cpu-limit                   enforcer cpu limit in cores ( default value = 2 )
```

**Syntax: Deploy VM Enforcer with TLS enabled**

```shell
  sudo ./install_vme.sh --version <version> -u <username> -p <password> --token <vm_enforcer_token> --gateway <dns/ip:port> --rootca-file <rootca_path> --publiccert-file <client_cert_path> --privatekey-file <client_key_path> --khulnasoft-tls-verify true

```

## Uninstall

```
curl -s https://raw.githubusercontent.com/khulnasoft/deployments/2022.4/enforcers/vm_enforcer/shell/uninstall_vme.sh | bash
```
