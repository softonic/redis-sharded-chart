{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "redis-sharded.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "redis-sharded.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "redis-sharded.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "redis-sharded.labels" -}}
helm.sh/chart: {{ include "redis-sharded.chart" . }}
{{ include "redis-sharded.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "redis-sharded.selectorLabels" -}}
app.kubernetes.io/name: {{ include "redis-sharded.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Selector labels twemproxy
*/}}
{{- define "redis-sharded.twemproxySelectorLabels" -}}
app.kubernetes.io/name: {{ include "redis-sharded.name" . }}-twemproxy
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "redis-sharded.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "redis-sharded.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
  Create redis connections list with weight 1, based in the number of stateful sets and the specified name.
*/}}
{{- define "redis-sharded.connectionsList" -}}
{{- $redisName := include "redis-sharded.fullname" . -}}
{{- $redisPort := (.Values.redisPort | int) -}}
{{- range $i, $e := until (.Values.replicaCount|int) -}}
- {{ printf "%s-%d.%s-backend:%d:1\n" $redisName $i $redisName $redisPort }}
{{- end -}}
{{- end -}}


{{/*
  Generate nutcracker config
*/}}
{{- define "redis-sharded.nutcrackerConfig" -}}
redis:
  listen: 0.0.0.0:{{ .Values.redisPort }}
  redis: true
{{- with .Values.twemproxy.config }}
{{ toYaml . | indent 2 }}
{{- end }}
  servers:
{{ include "redis-sharded.connectionsList" . | indent 2 }}
{{- end -}}

