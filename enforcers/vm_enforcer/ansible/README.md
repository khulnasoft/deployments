# Deploy VM Enforcer using Ansible Playbook

## Overview

You can use an Ansible playbook to deploy VM Enforcers on the desired VM Enforcer group. This procedure is supported for Linux platforms only.

## Prerequisites

* VM Enforcer Group token. Refer to [Create a VM Enforcer Group and VM Enforcer](https://docs.khulnasoft.com/docs/create-a-vm-enforcer-group-and-vm-enforcer) to create this token.
* Khulnasoft username and password
* The following packages:
   * runC
   * wget

## Preparation

**Step 1. Download the Ansible playbook**

```shell
git clone https://github.com/khulnasoft/deployments.git -b 2022.4
cd ./deployments/enforcers/vm_enforcer/ansible/
```

**Step 2. Create a `hosts` file with the IP or DNS addresses of the VM(s).** For example:

```bash
[all]     # list the IP/DNS addresses of the VMs to deploy VM Enforcer
10.0.0.1       ansible_ssh_private_key_file=~/.ssh/test-key    ansible_user=test-user
10.0.0.x       ansible_ssh_private_key_file=~/.ssh/test-key
test.khulnasoft.com  ansible_user=test-user
```

## Deploy VM Enforcers on all VMs using ansible-playbook

Add the [mandatory\optional variables](#mandatory-variables) with the `--extra-vars` flag in the deployment command as shown below, and run the command.

Mandatory:
 * USERNAME
 * PASSWORD
 * ENFORCER_VERSION
 * TOKEN
 * GATEWAY_ENDPOINT

Optional (**MANDATORY** for khulnasoft **cloud** users with value `true`)
 * KHULNASOFT_TLS_VERIFY_VALUE

```shell
ansible-playbook vm-enforcer.yaml -i ./path/to/hosts -e vme_install=true --extra-vars "USERNAME=<username> PASSWORD=<password> ENFORCER_VERSION=<version> TOKEN=<token> GATEWAY_ENDPOINT=<endpoint>:<port>
KHULNASOFT_TLS_VERIFY=<KHULNASOFT_TLS_VERIFY_VALUE>"
 
```
##  Uninstall VM Enforcer from all VMs using ansible-playbook

```shell
ansible-playbook vm-enforcer.yaml -i ./path/to/hosts -e vme_uninstall=true
```

## References
* Getting started with [Ansible](https://docs.ansible.com/ansible/latest/user_guide/intro_getting_started.html) and [Run your first Playbook](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html) guides.
* [Khulnasoft VM Enforcer Overview](../README.md) and all other [Khulnasoft Enforcers types](../../README.md) overview
* Khulnasoft VM Enforcers [official documentation](https://docs.khulnasoft.com/docs/vm-enforcer)
