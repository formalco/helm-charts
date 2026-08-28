{{- define "azure-gar-cred.job" -}}
{{- $clientId := required "azure.clientId is required (use the managed identity client ID, not its object ID)" .Values.azure.clientId -}}
{{- $tenantId := required "azure.tenantId is required" .Values.azure.tenantId -}}
{{- $entraAudience := required "azure.audience is required" .Values.azure.audience -}}
{{- $projectNumber := required "gcp.projectNumber is required" .Values.gcp.projectNumber -}}
{{- $poolId := required "gcp.poolId is required" .Values.gcp.poolId -}}
{{- $providerId := required "gcp.providerId is required" .Values.gcp.providerId -}}
{{- $serviceAccountEmail := required "gcp.serviceAccountEmail is required" .Values.gcp.serviceAccountEmail -}}
{{- $registryHost := required "gcp.registryHost is required" .Values.gcp.registryHost -}}
activeDeadlineSeconds: {{ .Values.activeDeadlineSeconds }}
template:
  metadata:
    labels:
      azure.workload.identity/use: "true"
      {{- with omit .Values.podLabels "azure.workload.identity/use" }}
      {{- toYaml . | nindent 6 }}
      {{- end }}
  spec:
    serviceAccountName: formal-gar-secret-manager
    containers:
      - name: azure-gar-cred-helper
        {{- if .Values.image.digest }}
        image: "{{ .Values.image.repository }}@{{ .Values.image.digest }}"
        {{- else }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        {{- end }}
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 100m
            memory: 128Mi
        command:
          - /bin/bash
          - -c
          - |
            set -euo pipefail

            ENTRA_ACCESS_TOKEN="$(
              curl --fail-with-body --silent --show-error --max-time 30 \
                --request POST \
                --header "Content-Type: application/x-www-form-urlencoded" \
                --data-urlencode "grant_type=client_credentials" \
                --data-urlencode "client_id=${AZURE_CLIENT_ID}" \
                --data-urlencode "client_assertion_type=urn:ietf:params:oauth:client-assertion-type:jwt-bearer" \
                --data-urlencode "client_assertion=$(cat "${AZURE_FEDERATED_TOKEN_FILE}")" \
                --data-urlencode "scope=${FORMAL_ENTRA_AUDIENCE%/}/.default" \
                "https://login.microsoftonline.com/${AZURE_TENANT_ID}/oauth2/v2.0/token" |
                jq -er '.access_token'
            )"

            GCP_STS_AUDIENCE="//iam.googleapis.com/projects/${GCP_PROJECT_NUMBER}/locations/global/workloadIdentityPools/${GCP_POOL_ID}/providers/${GCP_PROVIDER_ID}"
            GCP_STS_ACCESS_TOKEN="$(
              jq -n \
                --arg audience "${GCP_STS_AUDIENCE}" \
                --arg subjectToken "${ENTRA_ACCESS_TOKEN}" \
                '{
                  audience: $audience,
                  grantType: "urn:ietf:params:oauth:grant-type:token-exchange",
                  requestedTokenType: "urn:ietf:params:oauth:token-type:access_token",
                  scope: "https://www.googleapis.com/auth/cloud-platform",
                  subjectToken: $subjectToken,
                  subjectTokenType: "urn:ietf:params:oauth:token-type:jwt"
                }' |
                curl --fail-with-body --silent --show-error --max-time 30 \
                  --request POST \
                  --header "Content-Type: application/json" \
                  --data-binary @- \
                  "https://sts.googleapis.com/v1/token" |
                jq -er '.access_token'
            )"

            GCP_ACCESS_TOKEN="$(
              jq -n '{
                scope: ["https://www.googleapis.com/auth/cloud-platform"],
                lifetime: "3600s"
              }' |
                curl --fail-with-body --silent --show-error --max-time 30 \
                  --request POST \
                  --header "Authorization: Bearer ${GCP_STS_ACCESS_TOKEN}" \
                  --header "Content-Type: application/json" \
                  --data-binary @- \
                  "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/${GCP_SERVICE_ACCOUNT_EMAIL}:generateAccessToken" |
                jq -er '.accessToken'
            )"

            kubectl create secret docker-registry formal-ecr-secret \
              --docker-server="${GCP_REGISTRY_HOST}" \
              --docker-username=oauth2accesstoken \
              --docker-password="${GCP_ACCESS_TOKEN}" \
              --dry-run=client \
              --output=yaml |
              kubectl apply --server-side --field-manager=gar-cred --filename=-
        env:
          - name: FORMAL_ENTRA_AUDIENCE
            value: {{ $entraAudience | quote }}
          - name: GCP_PROJECT_NUMBER
            value: {{ $projectNumber | quote }}
          - name: GCP_POOL_ID
            value: {{ $poolId | quote }}
          - name: GCP_PROVIDER_ID
            value: {{ $providerId | quote }}
          - name: GCP_SERVICE_ACCOUNT_EMAIL
            value: {{ $serviceAccountEmail | quote }}
          - name: GCP_REGISTRY_HOST
            value: {{ $registryHost | quote }}
    restartPolicy: OnFailure
    {{- with .Values.nodeSelector }}
    nodeSelector:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .Values.affinity }}
    affinity:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .Values.tolerations }}
    tolerations:
      {{- toYaml . | nindent 6 }}
    {{- end }}
{{- end }}
