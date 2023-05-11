{{- define "ghost.image" -}}
{{ .Values.ghost.image.repository }}:{{ .Values.ghost.image.tag }}
{{- end -}}

{{- define "mysql.image" -}}
{{ .Values.mysql.image.repository }}:{{ .Values.mysql.image.tag }}
{{- end -}}

{{- define "mysql.host" -}}
{{ .Release.Name }}-mysql.{{ .Release.Namespace }}.svc.cluster.local
{{- end -}}

{{- define "ghost.fullName" -}}
{{ .Release.Name }}-ghost
{{- end -}}

{{- define "ghost.serviceName" -}}
{{ .Release.Name }}-ghost-service
{{- end -}}
