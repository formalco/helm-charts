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
Validate Formal authentication: an API key or exactly one OIDC source.
*/}}
{{- define "kubernetes-operator.validateAuth" -}}
{{- include "formal-common.validateAPIKey" . -}}
{{- $hasAPIKey := include "formal-common.hasAPIKey" . -}}
{{- $sources := compact (splitList "," (include "kubernetes-operator.oidcSources" .)) -}}
{{- $hasOIDC := gt (len $sources) 0 -}}
{{- $hasID := and .Values.oidc .Values.oidc.integration_id -}}
{{- if and $hasAPIKey $hasOIDC -}}
{{- fail "oidc is mutually exclusive with formalAPIKey and formalAPIKeySecret" -}}
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

