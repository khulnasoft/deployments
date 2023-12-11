# Deploy Khulnasoft Enterprise using Operator

You can deploy Khulnasoft Enterprise with all the components in a single cluster using a Kubernetes Operator. Use the following resources from the khulnasoft-operator repository:

* [Deploy Khulnasoft Operator in your OpenShift cluster](https://github.com/khulnasoft/khulnasoft-operator/blob/2022.4/docs/DeployOpenShiftOperator.md#deploying-the-khulnasoft-operator)
* Deploy Khulnasoft server using [KhulnasoftCSP CRD](https://github.com/khulnasoft/khulnasoft-operator/blob/2022.4/deploy/crds/operator_v1alpha1_khulnasoftcsp_cr.yaml) and by following the [deployment instructions](https://github.com/khulnasoft/khulnasoft-operator/blob/2022.4/docs/DeployOpenShiftOperator.md#deploying-khulnasoft-enterprise-using-custom-resources)
* You can refer CR usage examples from the [Operator repository](https://github.com/khulnasoft/khulnasoft-operator/blob/2022.4/docs/DeployOpenShiftOperator.md#Example-Deploying-the-Khulnasoft-Server-with-an-Khulnasoft-Enforcer-and-KubeEnforcer-all-in-one-CR)

Ensure that you use the latest branch of the Khulnasoft Security Operator repository.