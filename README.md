<a href="https://joinformal.com">
    <img src=".github/formal_logo.svg" alt="Formal logo" title="Formal" align="right" height="50" />
</a>

# Formal Helm Charts

[joinformal.com](https://joinformal.com)

This repository contains Helm Charts to deploy Formal on your Kubernetes cluster.

## Available Charts

| Charts                                            | Description                                                               |
| ------------------------------------------------- | ------------------------------------------------------------------------- |
| [connector](charts/formal-connector)       | Formal Connector Helm Chart.                                              |

## Adding the Helm Repository

The Formal Helm repository can be added using the `helm repo add`
command, like in the following example:

```
$ helm repo add formal https://formalco.github.io/helm-charts
"formal" has been added to your repositories
```

You can then install the charts using the `helm install` command:

```
$ helm install formal-connector formal/connector
```

## Questions

Our team always welcomes any and all questions -- don't hesitate to reach out to a team member directly.
