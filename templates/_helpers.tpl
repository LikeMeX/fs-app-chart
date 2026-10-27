{{/*
Expand the name of the chart.
*/}}
{{- define "my-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "my-app.fullname" -}}
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
{{- define "my-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "my-app.labels" -}}
helm.sh/chart: {{ include "my-app.chart" . }}
{{ include "my-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "my-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "my-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "my-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "my-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Cloud SQL Auth Proxy as a native sidecar (an init container with restartPolicy Always): starts,
and passes its startup probe, before the main container; stops after it. Logs in to Postgres as
the pod's Workload Identity service account; the main container connects to 127.0.0.1:<port> with
user "<gsa>@<project>.iam" and no password. Shared by the Deployment and the migration Job.
Call with .Values.cloudSqlProxy.
*/}}
{{- define "my-app.cloudSqlProxy" -}}
- name: cloud-sql-proxy
  image: {{ .image }}
  restartPolicy: Always
  args:
    - --auto-iam-authn
    - --private-ip
    - --structured-logs
    - --health-check
    - --http-address=0.0.0.0
    - --http-port=9090
    - --port={{ .port }}
    - {{ required "cloudSqlProxy.instance is required" .instance }}
  startupProbe:
    httpGet:
      path: /startup
      port: 9090
    periodSeconds: 1
    failureThreshold: 60
  livenessProbe:
    httpGet:
      path: /liveness
      port: 9090
    periodSeconds: 10
  securityContext:
    runAsNonRoot: true
    allowPrivilegeEscalation: false
    readOnlyRootFilesystem: true
  resources:
    {{- toYaml .resources | nindent 4 }}
{{- end }}

{{/*
envFrom for the app container: external secrets, the chart's own secret, and the configmap the
deploy workflow creates from env/.env.<environment>. Shared by the Deployment and the migration Job.
*/}}
{{- define "my-app.envFrom" -}}
{{- range $v := .Values.external_secret_refs }}
- secretRef:
    name: {{ $v.name }}
{{- end }}
{{- if .Values.secrets }}
- secretRef:
    name: {{ include "my-app.fullname" . }}
{{- end }}
- configMapRef:
    name: {{ include "my-app.fullname" . }}
{{- end }}
