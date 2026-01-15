{{/*
Expand the name of the chart.
*/}}
{{- define "ai-satellite.name" -}}
{{- printf "formal-%s" (default .Chart.Name .Values.nameOverride | trunc 57 | trimSuffix "-") }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ai-satellite.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- printf "formal-%s" (.Values.fullnameOverride | trunc 57 | trimSuffix "-") }}
{{- else }}
{{- printf "formal-ai-satellite" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ai-satellite.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ai-satellite.labels" -}}
helm.sh/chart: {{ include "ai-satellite.chart" . }}
{{ include "ai-satellite.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ai-satellite.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ai-satellite.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ai-satellite.serviceAccountName" -}}
{{- if .Values.serviceAccount.name }}
{{- .Values.serviceAccount.name }}
{{- else if .Values.serviceAccount.create }}
{{- include "ai-satellite.fullname" . }}
{{- else }}
{{- fail "Cannot determine service account name. Either set serviceAccount.create=true or provide serviceAccount.name" }}
{{- end }}
{{- end }}
