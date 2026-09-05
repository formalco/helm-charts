{{/*
Expand the name of the chart.
*/}}
{{- define "kubernetes-operator.name" -}}
{{- printf "formal-%s" (default .Chart.Name .Values.nameOverride | trunc 56 | trimSuffix "-") }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "kubernetes-operator.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- printf "formal-%s" (.Values.fullnameOverride | trunc 56 | trimSuffix "-") }}
{{- else }}
{{- printf "formal-kubernetes-operator" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kubernetes-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "kubernetes-operator.labels" -}}
helm.sh/chart: {{ include "kubernetes-operator.chart" . }}
{{ include "kubernetes-operator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "kubernetes-operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kubernetes-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Comma-separated OIDC source keys (every oidc.* map except integration_id).
*/}}
{{- define "kubernetes-operator.oidcSources" -}}
{{- $sources := list -}}
{{- range $key, $val := .Values.oidc }}
{{- if and (ne $key "integration_id") (kindIs "map" $val) }}
{{- $sources = append $sources $key -}}
{{- end }}
{{- end }}
{{- join "," $sources -}}
{{- end }}

{{/*
Validate Formal authentication: API key or exactly one OIDC source.
*/}}
{{- define "kubernetes-operator.validateAuth" -}}
{{- $hasAPIKey := .Values.formalAPIKey -}}
{{- $sources := compact (splitList "," (include "kubernetes-operator.oidcSources" .)) -}}
{{- $hasOIDC := gt (len $sources) 0 -}}
{{- $hasID := and .Values.oidc .Values.oidc.integration_id -}}
{{- if and $hasAPIKey $hasOIDC -}}
{{- fail "formalAPIKey and oidc are mutually exclusive" -}}
{{- end -}}
{{- if gt (len $sources) 1 -}}
{{- fail "oidc sources are mutually exclusive" -}}
{{- end -}}
{{- if and $hasOIDC (not $hasID) -}}
{{- fail "oidc.integration_id is required with an oidc source" -}}
{{- end -}}
{{- if and $hasID (not $hasOIDC) -}}
{{- fail "an oidc source is required" -}}
{{- end -}}
{{- end }}

