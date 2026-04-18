{{- define "app.name" -}}
app
{{- end }}

{{- define "app.fullname" -}}
{{ .Release.Name }}-{{ include "app.name" . }}
{{- end }}