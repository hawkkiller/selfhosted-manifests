{{- define "ghost.image" -}}
{{ .Values.container.image }}:{{ .Values.container.image.tag }}
{{- end -}}