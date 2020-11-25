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

{{- define "storm.logging.name" -}}
{{- printf "%s-logging" (include "storm.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "storm.zookeeper.port" -}}
{{- ternary .Values.zookeeper.service.ports.client.port (default 2181 .Values.zookeeper.port) .Values.zookeeper.enabled -}}
{{- end -}}

{{- define "storm.zookeeper.config" -}}
{{- $servers := list (include "storm.zookeeper.fullname" .) -}}
{{- if not .Values.zookeeper.enabled -}}
{{- $nullcheck := required "If not using the Storm chart's built-in Zookeeper (i.e. `.Values.zookeeper.enabled: false`), `.Values.zookeeper.servers` is required" .Values.zookeeper.servers -}}
{{- $servers = .Values.zookeeper.servers -}}
{{- end -}}
{{- dict "servers" $servers | toJson -}}
{{- end -}}

{{- define "storm.nimbus.initCommand" -}}
{{- $servers := get ((include "storm.zookeeper.config" .) | fromJson) "servers" -}}
{{- $checks := list -}}
{{- range $server := $servers -}}
{{- $checks = append $checks (printf "zkCli.sh -server %s:%s ls /" $server (include "storm.zookeeper.port" $)) -}}
{{- end -}}
{{- $checkCommand := join " || " $checks -}}
{{- printf "until %s; do echo waiting for %v; sleep 10; done" $checkCommand $servers -}}
{{- end -}}
