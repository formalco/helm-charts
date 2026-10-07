{{/*
Templates shared by the Formal charts. Call each one with the root context of
the chart that includes it, so .Chart and .Values are that chart's values.
*/}}

{{- define "formal-common.name" -}}
{{- printf "formal-%s" (default .Chart.Name .Values.nameOverride | trunc 56 | trimSuffix "-") }}
{{- end }}

{{- define "formal-common.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- printf "formal-%s" (.Values.fullnameOverride | trunc 56 | trimSuffix "-") }}
{{- else }}
{{- printf "formal-%s" .Chart.Name }}
{{- end }}
{{- end }}

{{- define "formal-common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "formal-common.labels" -}}
helm.sh/chart: {{ include "formal-common.chart" . }}
{{ include "formal-common.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "formal-common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "formal-common.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "formal-common.serviceAccountName" -}}
{{- if .Values.serviceAccount.name }}
{{- .Values.serviceAccount.name }}
{{- else if .Values.serviceAccount.create }}
{{- include "formal-common.fullname" . }}
{{- else }}
{{- fail "Cannot determine service account name. Either set serviceAccount.create=true or provide serviceAccount.name" }}
{{- end }}
{{- end }}

{{/*
API key. formalAPIKey makes the chart create a Secret; formalAPIKeySecret
references a Secret that the chart does not manage.
*/}}
{{- define "formal-common.validateAPIKey" -}}
{{- $ref := .Values.formalAPIKeySecret | default dict -}}
{{- if and .Values.formalAPIKey (or $ref.name $ref.key) -}}
{{- fail "formalAPIKey and formalAPIKeySecret are mutually exclusive" -}}
{{- end -}}
{{- if and $ref.name (not $ref.key) -}}
{{- fail "formalAPIKeySecret.key is required with formalAPIKeySecret.name" -}}
{{- end -}}
{{- if and $ref.key (not $ref.name) -}}
{{- fail "formalAPIKeySecret.name is required with formalAPIKeySecret.key" -}}
{{- end -}}
{{- end }}

{{/*
"true" when formalAPIKey or formalAPIKeySecret is set, else empty.
*/}}
{{- define "formal-common.hasAPIKey" -}}
{{- $ref := .Values.formalAPIKeySecret | default dict -}}
{{- if or .Values.formalAPIKey $ref.name }}true{{ end -}}
{{- end }}

{{- define "formal-common.apiKeySecretName" -}}
{{- $ref := .Values.formalAPIKeySecret | default dict -}}
{{- $ref.name | default (include "formal-common.fullname" .) -}}
{{- end }}

{{- define "formal-common.apiKeySecretKey" -}}
{{- $ref := .Values.formalAPIKeySecret | default dict -}}
{{- $ref.key | default "formal-api-key" -}}
{{- end }}

{{- define "formal-common.apiKeySecret" -}}
{{- if .Values.formalAPIKey }}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "formal-common.fullname" . }}
  labels:
    {{- include "formal-common.labels" . | nindent 4 }}
type: Opaque
data:
  formal-api-key: {{ .Values.formalAPIKey | b64enc }}
{{- end }}
{{- end }}

{{/*
Container env from .Values.env: a list of EnvVar, or a map of name to a value
or to an EnvVar body. Renders list items at the current indentation.
*/}}
{{- define "formal-common.env" -}}
{{- if kindIs "slice" .Values.env }}
{{- with .Values.env }}
{{ toYaml . }}
{{- end }}
{{- else }}
{{- range $name, $value := .Values.env }}
{{- if kindIs "map" $value }}
- name: {{ $name }}
  {{- toYaml $value | nindent 2 }}
{{- else if not (kindIs "invalid" $value) }}
- name: {{ $name }}
  value: {{ $value | toString | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "formal-common.extraManifests" -}}
{{- range .Values.extraManifests }}
---
{{ toYaml . }}
{{- end }}
{{- end }}
