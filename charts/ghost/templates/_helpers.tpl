{{- define "ghost.image" -}}
{{ .Values.ghost.image.repository }}:{{ .Values.ghost.image.tag }}
{{- end -}}

{{- define "litestream.image" -}}
{{ .Values.litestream.image.repository }}:{{ .Values.litestream.image.tag }}
{{- end -}}

{{- define "litestream.s3.path" -}}
s3://{{- .Values.litestream.replicatePathS3 -}}
{{- end -}}

{{- define "mysql.image" -}}
{{ .Values.database.mysql.image.repository }}:{{ .Values.database.mysql.image.tag }}
{{- end -}}
