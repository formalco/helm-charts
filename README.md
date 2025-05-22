<a href="https://joinformal.com">
    <img src=".github/formal_logo.svg" alt="Formal logo" title="Formal" align="right" height="50" />
</a>

# Formal Helm Charts

[joinformal.com](https://joinformal.com)

This repository contains Helm Charts to deploy Formal on your Kubernetes cluster.

## Available Charts

| Charts                        | Description                                                                                                                     |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------|
| [connector](charts/connector) | Formal Connector base Helm chart.                                                                                               |
| [ecr-cred](charts/ecr-cred)   | ECR credentials job. Required for non-AWS environments. Requires `pullWithCredentials=true` in the Connector Helm chart values. |

## Using the Helm Repository

To get started with the Formal Helm charts, first add the Formal Helm repository:

```
$ helm repo add formal https://formalco.github.io/helm-charts
"formal" has been added to your repositories
```

Next, retrieve the default values and save them to a local file for
customization:

```
$ helm show values formal/connector > values.yaml
```

You can then edit `values.yaml` to fit your deployment needs. For the
Connector, you will need to update the API key and set at least one
port.

Finally, install the Connector chart using:

```
$ helm install formal-connector formal/connector -f values.yaml
```

## Questions

Our team always welcomes any and all questions -- don't hesitate to reach out to a team member directly.
