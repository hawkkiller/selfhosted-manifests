{{- define "ghost.image" -}}
{{ .Values.container.image.repository }}:{{ .Values.container.image.tag }}
{{- end -}}