{{/*
Expand the name of the chart.
*/}}
{{- define "policy-data-loader-satellite.name" -}}
{{- printf "formal-%s" (default .Chart.Name .Values.nameOverride | trunc 56 | trimSuffix "-") }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "policy-data-loader-satellite.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- printf "formal-%s" (.Values.fullnameOverride | trunc 56 | trimSuffix "-") }}
{{- else }}
{{- printf "formal-policy-data-loader-satellite" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "policy-data-loader-satellite.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "policy-data-loader-satellite.labels" -}}
helm.sh/chart: {{ include "policy-data-loader-satellite.chart" . }}
{{ include "policy-data-loader-satellite.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "policy-data-loader-satellite.selectorLabels" -}}
app.kubernetes.io/name: {{ include "policy-data-loader-satellite.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "policy-data-loader-satellite.serviceAccountName" -}}
{{- if .Values.serviceAccount.name }}
{{- .Values.serviceAccount.name }}
{{- else if .Values.serviceAccount.create }}
{{- include "policy-data-loader-satellite.fullname" . }}
{{- else }}
{{- fail "Cannot determine service account name. Either set serviceAccount.create=true or provide serviceAccount.name" }}
{{- end }}
{{- end }}
