{{/*
Expand the name of the chart.
*/}}
{{- define "kubernetes-operator.name" -}}
{{- printf "formal-%s" (default .Chart.Name .Values.nameOverride | trunc 57 | trimSuffix "-") }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "kubernetes-operator.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- printf "formal-%s" (.Values.fullnameOverride | trunc 57 | trimSuffix "-") }}
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

