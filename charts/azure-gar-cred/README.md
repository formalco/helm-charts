# GAR credentials for AKS

`azure-gar-cred` lets AKS workloads pull Formal images from Google Artifact Registry
without storing a Google service account key or a Formal-issued cloud access key
in the cluster. It exchanges the AKS user-assigned managed identity token through
Microsoft Entra ID and Google Workload Identity Federation, then impersonates
Formal's GAR pull service account.

This chart is for AKS only. Azure Container Apps cannot run this credential
refresh CronJob.

## Prerequisites

- Azure Workload Identity is enabled on the AKS cluster.
- A dedicated customer-managed user-assigned identity is available for image
  pulls.
- Formal has enabled that identity to impersonate a GAR pull service account.
- `pullWithCredentials: true` is set on each Formal workload chart.

Do not create Google service accounts, workload identity pools, providers, or
IAM bindings. Formal manages the Google Cloud resources.

Do not install `ecr-cred` and `azure-gar-cred` in the same namespace. Both manage the
`formal-ecr-secret` image pull secret and would overwrite each other's token.

## Configure the Azure identity

Retrieve the identity's tenant, client, and object IDs:

```sh
az identity show \
  --resource-group <identity-resource-group> \
  --name <managed-identity-name> \
  --query '{tenantId:tenantId,clientId:clientId,objectId:principalId}'
```

Send the `tenantId` and `objectId` to Formal. These identifiers are not secrets.
Formal uses them to authorize the identity in Google Cloud and returns the GCP
values required by this chart.

The `clientId` is a different identifier. Keep it for `azure.clientId` in the
Helm values.

Create an Azure federated identity credential for the chart's service account.
The subject namespace must match the namespace where the chart will be
installed:

```sh
AKS_OIDC_ISSUER=$(az aks show \
  --resource-group <aks-resource-group> \
  --name <aks-cluster-name> \
  --query oidcIssuerProfile.issuerUrl \
  --output tsv)

az identity federated-credential create \
  --resource-group <identity-resource-group> \
  --identity-name <managed-identity-name> \
  --name formal-azure-gar-cred \
  --issuer "${AKS_OIDC_ISSUER}" \
  --subject system:serviceaccount:<namespace>:formal-gar-secret-manager \
  --audiences api://AzureADTokenExchange
```

## Install the chart

Create a values file using the Azure identifiers and the non-secret GCP values
provided by Formal:

```yaml
azure:
  clientId: "<managed-identity-client-id>"
  tenantId: "<entra-tenant-id>"
  audience: "https://management.azure.com"
gcp:
  providerId: "<provided-by-formal>"
  serviceAccountEmail: "<provided-by-formal>"
schedule: "*/30 * * * *"
```

This chart creates registry credentials but does not change workload image
settings. Configure each workload chart to use its GAR repository:

```yaml
image:
  repository: us-docker.pkg.dev/formal-public-assets/formalco-prod-connector/formalco-prod-connector
pullWithCredentials: true
```

Use the corresponding GAR repository for each Satellite or Kubernetes Operator.

Install this chart before the workload charts. Its pre-install hook creates
`formal-ecr-secret` before those workloads start:

```sh
helm upgrade --install formal-azure-gar-cred formal/azure-gar-cred \
  --namespace formal \
  --values azure-gar-cred-values.yaml
```

The chart patches the Docker config secret in place with server-side apply,
avoiding the delete-and-create window in which kubelet could observe a missing
image pull secret.
