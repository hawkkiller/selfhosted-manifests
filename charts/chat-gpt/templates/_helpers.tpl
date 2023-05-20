{{- define "chat-gpt.image" -}}
{{ .Values.image.repository }}:{{ .Values.image.tag }}
{{- end }}

{{- define "chat-gpt.container.port" -}}
80
{{- end }}

{{- define "chat-gpt.container.name" -}}
chat-gpt
{{- end }}

{{- define "chat-gpt.service.name" -}}
chat-gpt
{{- end }}