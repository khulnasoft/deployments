# Deploy KubeEnforcer using Operator

You can deploy KubeEnforcer in your OpenShift cluster using a Kubernetes Operator. Use the following resources from the khulnasoft-operator repository:

* [Deploy Khulnasoft Operator in your OpenShift cluster](https://github.com/khulnasoft/khulnasoft-operator/blob/2022.4/docs/DeployOpenShiftOperator.md#deploying-the-khulnasoft-operator)
* Deploy KubeEnforcer using [KhulnasoftKubeEnforcer CRD](https://github.com/khulnasoft/khulnasoft-operator/blob/2022.4/deploy/crds/operator_v1alpha1_khulnasoftkubeenforcer_cr.yaml) and by following the [deployment instructions](https://github.com/khulnasoft/khulnasoft-operator/blob/2022.4/docs/DeployOpenShiftOperator.md#deploying-khulnasoft-enterprise-using-custom-resources)
* You can refer CR usage examples from the [Operator repository](https://github.com/khulnasoft/khulnasoft-operator/blob/2022.4/docs/DeployOpenShiftOperator.md#cr-examples)

Ensure that you use the latest branch of the Khulnasoft Security Operator repository.