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

{{- define "storm.logging.name" -}}
{{- printf "%s-logging" (include "storm.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "storm.config.name" -}}
{{- printf "%s-config" (include "storm.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "jmx.config.name" -}}
{{- printf "%s-jmx-config" (include "storm.fullname" .) | trunc 63 | trimSuffix "-" -}}
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

{{- define "storm.zookeeper.port" -}}
{{- if .Values.zookeeper.enabled -}}
    {{- $port := default 2181 .Values.zookeeper.service.port | toString -}}
    {{- printf "%s" $port -}}
{{- else -}}
    {{- $port := default 2181 .Values.zookeeper.port | toString -}}
    {{- printf "%s" $port  -}}
{{- end -}}
{{- end -}}

{{- define "storm.zookeeper.serverlist.yaml" -}}
{{- if .Values.zookeeper.enabled -}}
{{- printf "- \"%s\"" (include "storm.zookeeper.fullname" . ) -}}
{{- else -}}
{{- $nullcheck := required "If not using the Storm chart's built-in Zookeeper (i.e. `.Values.zookeeper.enabled: false`), `.Values.zookeeper.servers` is required" .Values.zookeeper.servers -}}
{{- tpl (.Values.zookeeper.servers | toYaml) $ -}}
{{- end -}}
{{- end -}}

{{- define "storm.zookeeper.image.repository" -}}
{{- if .Values.zookeeper.image -}}
{{- if .Values.zookeeper.image.repository -}}
    {{- $repo := default "bitnami/zookeeper" .Values.zookeeper.image.repository -}}
    {{- printf "%s" $repo -}}
{{- end -}}
{{- else -}}
    {{- printf "%s" "bitnami/zookeeper"  -}}
{{- end -}}
{{- end -}}

{{- define "storm.zookeeper.image.tag" -}}
{{- if .Values.zookeeper.image -}}
{{- if .Values.zookeeper.image.tag -}}
    {{- $tag := default "3.7.0" .Values.zookeeper.image.tag -}}
    {{- printf "%s" $tag -}}
{{- end -}}
{{- else -}}
    {{- printf "%s" "3.7.0"  -}}
{{- end -}}
{{- end -}}

{{- define "storm.zookeeper.image.pullPolicy" -}}
{{- if .Values.zookeeper.image -}}
{{- if .Values.zookeeper.image.pullPolicy -}}
    {{- $pullPolicy := default "IfNotPresent" .Values.zookeeper.image.pullPolicy -}}
    {{- printf "%s" $pullPolicy -}}
{{- end -}}
{{- else -}}
    {{- printf "%s" "IfNotPresent"  -}}
{{- end -}}
{{- end -}}

{{- define "storm.nimbus.initCommand" -}}
{{- $servers := ternary (list (include "storm.zookeeper.fullname" $ ))  .Values.zookeeper.servers .Values.zookeeper.enabled }}
{{- $checks := list -}}
{{- range $server := $servers -}}
{{- $checks = append $checks (printf "zkCli.sh -server %s:%s ls /" (tpl $server $) (include "storm.zookeeper.port" $)) -}}
{{- end -}}
{{- $checkCommand := join " || " $checks -}}
{{- printf "until %s; do echo waiting for %v; sleep 10; done" $checkCommand $servers -}}
{{- end -}}

{{/*
Return namespace to use
*/}}
{{- define "storm.namespace" -}}
    {{- if .Values.namespace }}
        {{- .Values.namespace -}}
    {{- else }}
        {{- .Release.Namespace -}}
    {{- end }}
{{- end -}}