{{/*
Expand the name of the chart.
*/}}
{{- define "azure-gar-cred.name" -}}
{{- printf "formal-%s" (default .Chart.Name .Values.nameOverride | trunc 56 | trimSuffix "-") }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "azure-gar-cred.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- printf "formal-%s" (.Values.fullnameOverride | trunc 56 | trimSuffix "-") }}
{{- else }}
{{- printf "formal-azure-gar-cred" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "azure-gar-cred.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "azure-gar-cred.labels" -}}
helm.sh/chart: {{ include "azure-gar-cred.chart" . }}
{{ include "azure-gar-cred.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "azure-gar-cred.selectorLabels" -}}
app.kubernetes.io/name: {{ include "azure-gar-cred.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
