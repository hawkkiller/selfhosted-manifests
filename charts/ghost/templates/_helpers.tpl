{{ define "ghost.image.full" }}
{{ .Values.container.image }}:{{ .Values.container.image.tag }}
{{ end }}