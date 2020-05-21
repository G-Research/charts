{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "siembol.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "siembol.fullname" -}}
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
{{- define "siembol.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "siembol.alerting.deploy.topology.name" -}}
{{- printf "%s-%s" (include "siembol.name" .) .Values.alerting.deploy.topology.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified alerting deploy topology name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "siembol.alerting.deploy.topology.fullname" -}}
{{- $name := default .Chart.Name .Values.alerting.deploy.topology.name -}}
{{- printf "%s-%s" (include "siembol.fullname" .) $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "siembol.alerting.deploy.rules.name" -}}
{{- printf "%s-%s" (include "siembol.name" .) .Values.alerting.deploy.rules.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a fully qualified alerting deploy rules name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "siembol.alerting.deploy.rules.fullname" -}}
{{- $name := default .Chart.Name .Values.alerting.deploy.rules.name -}}
{{- printf "%s-%s" (include "siembol.fullname" .) $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "siembol.labels" -}}
helm.sh/chart: {{ include "siembol.chart" . }}
{{ include "siembol.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "siembol.selectorLabels" -}}
app.kubernetes.io/name: {{ include "siembol.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "siembol.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "siembol.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Helps set the zookeeper url for the Kafka chart's Zookeeper
*/}}
{{- define "zookeeper.url" -}}
{{- printf "%s-%s" .Release.Name "storm-zookeeper" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Helps set the nimbus name for the Storm chart
*/}}
{{- define "storm.nimbus.fullname" -}}
{{- printf "%s-%s" .Release.Name "storm-nimbus" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Helps set the name for the Kafka chart
*/}}
{{- define "kafka.fullname" -}}
{{- printf "%s-%s" .Release.Name "kafka" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the config for the alerting Storm topology
*/}}
{{- define "siembol.alerting.config" -}}
{
  "alerts.engine": "siembol_alerts",
  "alerts.input.topic": "enrichments",
  "alerts.correlation.output.topic": "correlation.alerts",
  "kafka.error.topic": "errors",
  "alerts.output.topic": "alerts",
  "storm.attributes": {
    "bootstrap.servers": "{{ template "kafka.fullname" . }}:9092",
    "first.pool.offset.strategy": "EARLIEST",
    "kafka.spout.properties": {
      "group.id": "alerts.reader",
      "security.protocol": "PLAINTEXT"
    },
    "storm.config": {
      "num.workers": 1,
      "topology.message.timeout.secs": 50,
      "max.spout.pending": 5000
    }
  },
  "kafka.spout.num.executors": 1,
  "alerts.engine.bolt.num.executors": 1,
  "kafka.writer.bolt.num.executors": 1,
  "kafka.producer.properties": {
    "bootstrap.servers": "{{ template "kafka.fullname" . }}:9092",
    "compression.type": "snappy",
    "security.protocol": "PLAINTEXT",
    "client.id": "test_producer"
  },
  "zookeeper.attributes": {
    "zk.url": "{{ template "zookeeper.url" . }}",
    "zk.path": "/siembol/alerting",
    "zk.base.sleep.ms": 1000,
    "zk.max.retries": 10
  }
}
{{- end -}}
