{{/*
Expand the name of the chart.
*/}}
{{- define "privacera-helm-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "privacera-helm-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "privacera-helm-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "privacera-helm-chart.labels" -}}
helm.sh/chart: {{ include "privacera-helm-chart.chart" . }}
{{ include "privacera-helm-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "privacera-helm-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "privacera-helm-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate common labels for all resources
*/}}
{{- define "commonLabels" -}}
app: {{ .Values.app.name }}
app.kubernetes.io/name: {{ .Values.app.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ .Values.app.name }}
app.kubernetes.io/part-of: {{ .Values.app.name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.app.version }}
app.kubernetes.io/version: {{ .Values.app.version }}
{{- end }}
{{- end }}

{{/*
Generate selector labels (subset of common labels for selectors)
*/}}
{{- define "selectorLabels" -}}
app: {{ .Values.app.name }}
{{- end }}

{{/*
Generate full app name
*/}}
{{- define "fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Values.app.name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Generate standard resource names with suffixes
*/}}
{{- define "resourceName" -}}
{{- $name := include "fullname" . -}}
{{- if .suffix -}}
{{- printf "%s-%s" $name .suffix | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name -}}
{{- end -}}
{{- end }}

{{/*
Generate image pull secrets if configured
*/}}
{{- define "imagePullSecrets" -}}
{{- if .Values.image.pullSecrets }}
imagePullSecrets:
{{- range .Values.image.pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate standard metadata block
*/}}
{{- define "metadata" -}}
metadata:
  name: {{ include "resourceName" . }}
  namespace: {{ .Values.app.namespace }}
  labels:
    {{- include "commonLabels" . | nindent 4 }}
    {{- if .extraLabels }}
    {{- toYaml .extraLabels | nindent 4 }}
    {{- end }}
  {{- if .annotations }}
  annotations:
    {{- toYaml .annotations | nindent 4 }}
  {{- end }}
{{- end }}

{{/*
Chart name and version label
*/}}
{{- define "chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Convert YAML dict to properties format
*/}}
{{- define "toProperties" -}}
{{- $root := .root }}
{{- $data := .data }}
{{- range $key, $value := $data }}
{{- if and (kindIs "string" $value) (contains "{{" $value) }}
{{ $key }}={{ tpl $value $root }}
{{- else }}
{{ $key }}={{ $value }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Global-aware image configuration
*/}}
{{- define "globalImage" -}}
{{- $global := .Values.global.image | default dict -}}
{{- $local := .Values.image | default dict -}}
{{- $merged := merge $global $local -}}
hub: {{ $merged.hub | default "docker.io" }}
repository: {{ $merged.repository | default "nginx" }}
tag: {{ $merged.tag | default .Chart.AppVersion | default "latest" }}
pullPolicy: {{ $merged.pullPolicy | default "IfNotPresent" }}
{{- if or $merged.pullSecrets $global.pullSecrets }}
pullSecrets:
{{- range (concat ($merged.pullSecrets | default list) ($global.pullSecrets | default list) | uniq) }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Global-aware resources configuration
*/}}
{{- define "globalResources" -}}
{{- $global := .Values.global.resources | default dict -}}
{{- $local := .Values.resources | default dict -}}
{{- $merged := merge $local $global -}}
{{- if $merged }}
{{- omit $merged "enabled" | toYaml }}
{{- end }}
{{- end }}

{{/*
Global-aware service configuration
*/}}
{{- define "globalService" -}}
{{- $global := .Values.global.service | default dict -}}
{{- $local := .Values.service | default dict -}}
{{- $merged := merge $local $global -}}
type: {{ $merged.type | default "ClusterIP" }}
{{- if $merged.ports }}
ports:
{{- toYaml $merged.ports | nindent 2 }}
{{- end }}
{{- if or $merged.annotations $global.annotations }}
annotations:
{{- range $key, $value := (merge ($merged.annotations | default dict) ($global.annotations | default dict)) }}
  {{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Global-aware environment variables
*/}}
{{- define "globalEnv" -}}
{{- $global := .Values.global.env | default dict -}}
{{- $local := .Values.env | default dict -}}
{{- $merged := merge $local $global -}}
{{- $filtered := omit $merged "enabled" "variables" -}}
{{- range $key, $value := $filtered }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}

{{/*
Global-aware app configuration (labels, annotations)
*/}}
{{- define "globalApp" -}}
{{- $global := .Values.global.app | default dict -}}
{{- $local := .Values.app | default dict -}}
{{- $merged := merge $global $local -}}
{{- $globalNamespace := .Values.global.namespace | default "" -}}
name: {{ $merged.name | default "app-name" }}
namespace: {{ $globalNamespace | default $merged.namespace | default "default" }}
version: {{ $merged.version | default .Chart.AppVersion | default "" }}
{{- if or $merged.labels $global.labels }}
labels:
{{- range $key, $value := (merge ($merged.labels | default dict) ($global.labels | default dict)) }}
  {{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- if or $merged.annotations $global.annotations }}
annotations:
{{- range $key, $value := (merge ($merged.annotations | default dict) ($global.annotations | default dict)) }}
  {{ $key }}: {{ $value | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Global-aware security context
*/}}
{{- define "globalSecurityContext" -}}
{{- $global := .Values.global.securityContext | default dict -}}
{{- $local := .Values.securityContext | default dict -}}
{{- $merged := merge $local $global -}}
{{- if $merged }}
{{- omit $merged "enabled" | toYaml }}
{{- end }}
{{- end }}

{{/*
Global-aware node selector
*/}}
{{- define "globalNodeSelector" -}}
{{- $global := .Values.global.nodeSelector | default dict -}}
{{- $local := .Values.nodeSelector | default dict -}}
{{- $merged := merge $local $global -}}
{{- if $merged }}
{{- toYaml $merged }}
{{- end }}
{{- end }}

{{/*
Global-aware tolerations
*/}}
{{- define "globalTolerations" -}}
{{- $global := .Values.global.tolerations | default list -}}
{{- $local := .Values.tolerations | default list -}}
{{- $merged := concat $local $global | uniq -}}
{{- toYaml $merged }}
{{- end }}

{{/*
Global-aware affinity
*/}}
{{- define "globalAffinity" -}}
{{- $global := .Values.global.affinity | default dict -}}
{{- $local := .Values.affinity | default dict -}}
{{- $merged := merge $local $global -}}
{{- if $merged }}
{{- toYaml $merged }}
{{- end }}
{{- end }}

{{/*
Global-aware deployment configuration
*/}}
{{- define "globalDeployment" -}}
{{- $global := .Values.global.deployment | default dict -}}
{{- $local := .Values.deployment | default dict -}}
{{- $merged := merge $local $global -}}
{{- toYaml $merged }}
{{- end }}

{{/*
Global-aware statefulset configuration
*/}}
{{- define "globalStatefulset" -}}
{{- $global := .Values.global.statefulset | default dict -}}
{{- $local := .Values.statefulset | default dict -}}
{{- $merged := merge $local $global -}}
{{- toYaml $merged }}
{{- end }}

{{/*
Global-aware terminationGracePeriodSeconds
*/}}
{{- define "globalTerminationGracePeriodSeconds" -}}
{{- $global := "" }}
{{- if .Values.global }}
  {{- $global = .Values.global.terminationGracePeriodSeconds }}
{{- end }}
{{- $local := .Values.terminationGracePeriodSeconds -}}
{{- coalesce $local $global 30 }}
{{- end }}

{{/*
Global-aware init containers (array merge) - returns the merged list directly
*/}}
{{- define "globalInitContainers" -}}
{{- $global := list }}
{{- if .Values.global }}
  {{- $global = .Values.global.initContainers | default list }}
{{- end }}
{{- $local := .Values.initContainers | default list -}}
{{- $merged := concat $global $local -}}
{{- $merged }}
{{- end }}

{{/*
Global-aware additional containers (array merge) - returns the merged list directly
*/}}
{{- define "globalAdditionalContainers" -}}
{{- $global := list }}
{{- if .Values.global }}
  {{- $global = .Values.global.additionalContainers | default list }}
{{- end }}
{{- $local := .Values.additionalContainers | default list -}}
{{- $merged := concat $global $local -}}
{{- $merged }}
{{- end }}

{{/*
Global-aware secrets configuration
*/}}
{{- define "globalSecrets" -}}
{{- $global := dict }}
{{- if .Values.global }}
  {{- $global = .Values.global.secrets | default dict }}
{{- end }}
{{- $local := .Values.secrets | default dict -}}
{{- $merged := merge $local $global -}}
{{- toYaml $merged }}
{{- end }}

{{/*
Global-aware ingress configuration
*/}}
{{- define "globalIngress" -}}
{{- $global := .Values.global.ingress | default dict -}}
{{- $local := .Values.ingress | default dict -}}
{{- $merged := merge $local $global -}}
{{- toYaml $merged }}
{{- end }}

{{/*
Global-aware autoscaling configuration
*/}}
{{- define "globalAutoscaling" -}}
{{- $global := dict }}
{{- if .Values.global }}
  {{- $global = .Values.global.autoscaling | default dict }}
{{- end }}
{{- $local := .Values.autoscaling | default dict -}}
{{- $merged := merge $local $global -}}
{{- toYaml $merged }}
{{- end }}

{{/*
Global-aware scaledobject configuration
*/}}
{{- define "globalScaledObject" -}}
{{- $global := .Values.global.scaledobject | default dict -}}
{{- $local := .Values.scaledobject | default dict -}}
{{- $merged := merge $local $global -}}
{{- toYaml $merged }}
{{- end }}

{{/*
Global-aware pod disruption budget configuration
*/}}
{{- define "globalPodDisruptionBudget" -}}
{{- $global := .Values.global.podDisruptionBudget | default dict -}}
{{- $local := .Values.podDisruptionBudget | default dict -}}
{{- $merged := merge $local $global -}}
{{- toYaml $merged }}
{{- end }}

{{/*
Global-aware topology spread constraints configuration
*/}}
{{- define "globalTopologySpreadConstraints" -}}
{{- $global := .Values.global.topologySpreadConstraints | default dict -}}
{{- $local := .Values.topologySpreadConstraints | default dict -}}
{{- $merged := merge $local $global -}}
{{- toYaml $merged }}
{{- end }}

{{/*
Global-aware PersistentVolumeClaims configuration
*/}}
{{- define "globalPersistentVolumeClaims" -}}
{{- $global := dict }}
{{- if .Values.global }}
  {{- $global = .Values.global.persistentVolumeClaims | default dict }}
{{- end }}
{{- $local := .Values.persistentVolumeClaims | default dict -}}
{{- $merged := merge $local $global -}}
{{- toYaml $merged }}
{{- end }}

{{/*
Global-aware EmptyDir volumes configuration
*/}}
{{- define "globalEmptyDirVolumes" -}}
{{- $global := dict }}
{{- if .Values.global }}
  {{- $global = .Values.global.emptyDirVolumes | default dict }}
{{- end }}
{{- $local := .Values.emptyDirVolumes | default dict -}}
{{- $merged := merge $local $global -}}
{{- toYaml $merged }}
{{- end }}

{{/*
Generate ConfigMap name (defaults to fullname if not specified)
*/}}
{{- define "configMapName" -}}
{{- .Values.defaultConfigMap.name | default (include "fullname" .) }}
{{- end }}