{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "storm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "storm.fullname" -}}
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
{{- define "storm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "storm.nimbus.name" -}}
{{- printf "%s-%s" (include "storm.name" .) .Values.nimbus.service.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified nimbus name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "storm.nimbus.fullname" -}}
{{- $name := default .Chart.Name .Values.nimbus.service.name -}}
{{- printf "%s-%s" (include "storm.fullname" .) $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "storm.supervisor.name" -}}
{{- printf "%s-%s" (include "storm.name" .) .Values.supervisor.service.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified supervisor name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "storm.supervisor.fullname" -}}
{{- $name := default .Chart.Name .Values.supervisor.service.name -}}
{{- printf "%s-%s" (include "storm.fullname" .) $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "storm.ui.name" -}}
{{- printf "%s-%s" (include "storm.name" .) .Values.ui.service.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified ui name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "storm.ui.fullname" -}}
{{- $name := default .Chart.Name .Values.ui.service.name -}}
{{- printf "%s-%s" (include "storm.fullname" .) $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified zookeeper name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "storm.zookeeper.fullname" -}}
{{- if .Values.zookeeper.fullnameOverride -}}
{{- .Values.zookeeper.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "zookeeper" .Values.zookeeper.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "storm.zookeeper.client.port" -}}
{{- default 2181 .Values.zookeeper.service.ports.client.port -}}
{{- end -}}

{{- define "storm.logging.name" -}}
{{- printf "%s-logging" (include "storm.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "storm.zookeeper.configmap.servers" -}}
{{- if .Values.zookeeper.enabled -}}
{{ printf "[%s]" (include "storm.zookeeper.fullname" $) }}
{{- else -}}
{{- $nullcheck := required "If not using the Storm chart's built-in Zookeeper (i.e. `.Values.zookeeper.enabled: false`), `.Values.zookeeper.servers` is required" .Values.zookeeper.servers -}}
{{- range $server := .Values.zookeeper.servers }}
{{ printf "- %s" . | indent 6 }}
{{- end }}
{{- end }}
{{- end }}

# TODO: There must be a better way than duplicating this block twice.
{{- define "storm.nimbus.zookeeper.initContiners"}}
{{- if .Values.zookeeper.enabled }}
{{ printf "- name: init-%s" (include "storm.zookeeper.fullname" $) | indent 6 }}
{{ printf "image: %s:%s" $.Values.zookeeper.image.repository $.Values.zookeeper.image.tag | indent 8 }}
{{ printf "command: ['sh', '-c', 'until zkCli.sh -server %s:%s ls /; do echo waiting for %s; sleep 10; done']" (include "storm.zookeeper.fullname" $) (include "storm.zookeeper.client.port" $) (include "storm.zookeeper.fullname" $) | indent 8 }}
{{- else -}}
{{- $nullcheck := required "If not using the Storm chart's built-in Zookeeper (i.e. `.Values.zookeeper.enabled: false`), `.Values.zookeeper.servers` is required" .Values.zookeeper.servers -}}
{{- range $index, $server := .Values.zookeeper.servers }}
{{ printf "- name: init-zookeeper-%d" $index | indent 6 }}
{{ printf "image: %s:%s" $.Values.zookeeper.image.repository $.Values.zookeeper.image.tag | indent 8 }}
{{ printf "command: ['sh', '-c', 'until zkCli.sh -server %s:%s ls /; do echo waiting for %s; sleep 10; done']" $server (include "storm.zookeeper.client.port" $) $server | indent 8 }}
{{- end }}
{{- end }}
{{- end }}

{{- define "storm.configmap.data.yaml" }}
    ########### These MUST be filled in for a storm configuration
    storm.zookeeper.servers: {{ include "storm.zookeeper.configmap.servers" . }}
    storm.zookeeper.port: {{ template "storm.zookeeper.client.port" . }}
    nimbus.seeds: [{{ include "storm.nimbus.fullname" . }}]
    nimbus.thrift.port: {{ .Values.nimbus.service.port }}
    storm.log4j2.conf.dir: "/log4j2"
{{- end }}