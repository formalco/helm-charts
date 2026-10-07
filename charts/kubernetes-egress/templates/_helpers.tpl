{{- define "kubernetes-egress.celSidecar" -}}
Object.spec.initContainers{
  name: "formal-kubernetes-egress",
  {{- if .Values.sidecar.image.digest }}
  image: "{{ .Values.sidecar.image.repository }}@{{ .Values.sidecar.image.digest }}",
  {{- else }}
  image: "{{ .Values.sidecar.image.repository }}:{{ .Values.sidecar.image.tag }}",
  {{- end }}
  imagePullPolicy: {{ .Values.sidecar.image.pullPolicy | quote }},
  restartPolicy: "Always",
  env: [
    Object.spec.initContainers.env{
      name: "FORMAL_API_KEY",
      valueFrom: Object.spec.initContainers.env.valueFrom{
        secretKeyRef: Object.spec.initContainers.env.valueFrom.secretKeyRef{
          name: {{ required "formalAPIKeySecret.name is required" .Values.formalAPIKeySecret.name | quote }},
          key: {{ required "formalAPIKeySecret.key is required" .Values.formalAPIKeySecret.key | quote }}
        }
      }
    }
  ],
  securityContext: Object.spec.initContainers.securityContext{
    runAsUser: 0,
    runAsGroup: 0,
    allowPrivilegeEscalation: false,
    capabilities: Object.spec.initContainers.securityContext.capabilities{
      drop: ["ALL"],
      add: ["NET_ADMIN"]
    }
  },
  volumeMounts: [
    Object.spec.initContainers.volumeMounts{
      name: "formal-ca",
      mountPath: "/var/lib/formal/ca"
    }
  ],
  resources: Object.spec.initContainers.resources{
    requests: {
      "cpu": "{{ .Values.sidecar.resources.requests.cpu }}",
      "memory": "{{ .Values.sidecar.resources.requests.memory }}"
    },
    limits: {
      "cpu": "{{ .Values.sidecar.resources.limits.cpu }}",
      "memory": "{{ .Values.sidecar.resources.limits.memory }}"
    }
  }
}
{{- end }}
