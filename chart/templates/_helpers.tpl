{{/*
Copyright (c) 2025 VH & Co BV. Licensed under the Business Source License 1.1.

StackWeaver Helm Chart — shared template helpers.
*/}}

{{/*
Chart name (truncated to 63 chars, no trailing dash).
*/}}
{{- define "stackweaver.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified release name.
*/}}
{{- define "stackweaver.fullname" -}}
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
Chart label value.
*/}}
{{- define "stackweaver.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Standard labels.
*/}}
{{- define "stackweaver.labels" -}}
helm.sh/chart: {{ include "stackweaver.chart" . }}
{{ include "stackweaver.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | default .Chart.Version | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "stackweaver.selectorLabels" -}}
app.kubernetes.io/name: {{ include "stackweaver.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Service account name.
*/}}
{{- define "stackweaver.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "stackweaver.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Image pull secrets as YAML.
*/}}
{{- define "stackweaver.imagePullSecrets" -}}
{{- with .Values.global.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{/* ── Dependency host/port helpers ──────────────────────────────────────── */}}

{{/*
PostgreSQL host — internal K8s DNS when bundled.
*/}}
{{- define "stackweaver.postgresql.host" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" (include "stackweaver.fullname" .) }}
{{- else }}
{{- required "postgresql.external.host is required when postgresql.enabled=false" .Values.postgresql.external.host }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "stackweaver.postgresql.port" -}}
{{- if .Values.postgresql.enabled }}
{{- 5432 }}
{{- else }}
{{- .Values.postgresql.external.port | default 5432 }}
{{- end }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "stackweaver.postgresql.username" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.username }}
{{- else }}
{{- .Values.postgresql.external.username | default "iac" }}
{{- end }}
{{- end }}

{{/*
PostgreSQL database
*/}}
{{- define "stackweaver.postgresql.database" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.database }}
{{- else }}
{{- .Values.postgresql.external.database | default "iac_platform" }}
{{- end }}
{{- end }}

{{/*
PostgreSQL SSL mode
*/}}
{{- define "stackweaver.postgresql.sslmode" -}}
{{- if .Values.postgresql.enabled }}
{{- "disable" }}
{{- else }}
{{- .Values.postgresql.external.sslmode | default "disable" }}
{{- end }}
{{- end }}

{{/*
Redis host
*/}}
{{- define "stackweaver.redis.host" -}}
{{- if .Values.redis.enabled }}
{{- printf "%s-redis" (include "stackweaver.fullname" .) }}
{{- else }}
{{- required "redis.external.host is required when redis.enabled=false" .Values.redis.external.host }}
{{- end }}
{{- end }}

{{/*
Redis port
*/}}
{{- define "stackweaver.redis.port" -}}
{{- if .Values.redis.enabled }}
{{- 6379 }}
{{- else }}
{{- .Values.redis.external.port | default 6379 }}
{{- end }}
{{- end }}

{{/*
MinIO endpoint (host:port) — internal K8s DNS when bundled.
*/}}
{{- define "stackweaver.minio.endpoint" -}}
{{- if .Values.minio.enabled }}
{{- printf "%s-minio:9000" (include "stackweaver.fullname" .) }}
{{- else }}
{{- required "minio.external.endpoint is required when minio.enabled=false" .Values.minio.external.endpoint }}
{{- end }}
{{- end }}

{{/*
MinIO use SSL
*/}}
{{- define "stackweaver.minio.useSSL" -}}
{{- if .Values.minio.enabled }}
{{- false }}
{{- else }}
{{- .Values.minio.external.useSSL | default false }}
{{- end }}
{{- end }}

{{/* ── Secret reference helpers ──────────────────────────────────────────
     These helpers return the secret name for each component.
     Required secrets fail with a clear error when not set. */}}

{{- define "stackweaver.secrets.postgresql" -}}
{{- .Values.secrets.postgresql.secretName | default (printf "%s-postgresql" (include "stackweaver.fullname" .)) }}
{{- end }}

{{- define "stackweaver.secrets.redis" -}}
{{- .Values.secrets.redis.secretName | default "" }}
{{- end }}

{{- define "stackweaver.secrets.minio" -}}
{{- .Values.secrets.minio.secretName | default (printf "%s-minio" (include "stackweaver.fullname" .)) }}
{{- end }}

{{- define "stackweaver.secrets.encryption" -}}
{{- .Values.secrets.encryption.secretName | default (printf "%s-encryption" (include "stackweaver.fullname" .)) }}
{{- end }}

{{- define "stackweaver.secrets.zitadel" -}}
{{- .Values.secrets.zitadel.secretName | default (printf "%s-zitadel" (include "stackweaver.fullname" .)) }}
{{- end }}

{{- define "stackweaver.secrets.oidc" -}}
{{- .Values.secrets.oidc.secretName | default "" }}
{{- end }}

{{- define "stackweaver.secrets.githubApp" -}}
{{- .Values.secrets.githubApp.secretName | default "" }}
{{- end }}

{{/* ── Zitadel URL helpers ───────────────────────────────────────────── */}}

{{/*
Zitadel internal address (for in-cluster gRPC/HTTP calls between services).
*/}}
{{- define "stackweaver.zitadel.internalAddr" -}}
{{- if .Values.zitadel.bundled }}
{{- printf "%s-zitadel:8080" (include "stackweaver.fullname" .) }}
{{- else if .Values.zitadel.external.internalAddr }}
{{- .Values.zitadel.external.internalAddr }}
{{- else }}
{{- required "zitadel.external.issuer is required when zitadel.bundled=false" .Values.zitadel.external.issuer | trimPrefix "https://" | trimPrefix "http://" }}
{{- end }}
{{- end }}

{{/*
Zitadel external issuer URL (browser-reachable, used for OIDC iss claim validation).
*/}}
{{- define "stackweaver.zitadel.issuer" -}}
{{- if .Values.zitadel.bundled }}
{{- $scheme := ternary "https" "http" .Values.ingress.tls.enabled }}
{{- printf "%s://%s" $scheme .Values.ingress.hosts.auth }}
{{- else }}
{{- required "zitadel.external.issuer is required when zitadel.bundled=false" .Values.zitadel.external.issuer }}
{{- end }}
{{- end }}

{{/*
Login UI external base URL (browser-reachable).
*/}}
{{- define "stackweaver.loginUI.baseURL" -}}
{{- $scheme := ternary "https" "http" .Values.ingress.tls.enabled }}
{{- printf "%s://%s/ui/v2/login" $scheme .Values.ingress.hosts.auth }}
{{- end }}

{{/*
Login UI external origin.
*/}}
{{- define "stackweaver.loginUI.origin" -}}
{{- $scheme := ternary "https" "http" .Values.ingress.tls.enabled }}
{{- printf "%s://%s" $scheme .Values.ingress.hosts.auth }}
{{- end }}

{{/*
App external URL (frontend).
*/}}
{{- define "stackweaver.app.url" -}}
{{- $scheme := ternary "https" "http" .Values.ingress.tls.enabled }}
{{- printf "%s://%s" $scheme .Values.ingress.hosts.app }}
{{- end }}

{{/*
API external URL.
*/}}
{{- define "stackweaver.api.url" -}}
{{- printf "%s/api/v2" (include "stackweaver.app.url" .) }}
{{- end }}

{{/*
Frontend OIDC redirect URI.
*/}}
{{- define "stackweaver.frontend.redirectURI" -}}
{{- printf "%s/auth/callback" (include "stackweaver.app.url" .) }}
{{- end }}

{{/* ── Common env-var snippets (reused across deployments) ────────────── */}}

{{/*
Database env vars — shared between api, orchestrator, runner, ansible-runner.
*/}}
{{- define "stackweaver.env.database" -}}
- name: DATABASE_HOST
  value: {{ include "stackweaver.postgresql.host" . | quote }}
- name: DATABASE_PORT
  value: {{ include "stackweaver.postgresql.port" . | quote }}
- name: DATABASE_USER
  value: {{ include "stackweaver.postgresql.username" . | quote }}
- name: DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "stackweaver.secrets.postgresql" . }}
      key: {{ .Values.secrets.postgresql.keys.password }}
- name: DATABASE_NAME
  value: {{ include "stackweaver.postgresql.database" . | quote }}
- name: DATABASE_SSLMODE
  value: {{ include "stackweaver.postgresql.sslmode" . | quote }}
{{- end }}

{{/*
Redis env vars — shared between api, orchestrator, runner, ansible-runner.
*/}}
{{- define "stackweaver.env.redis" -}}
- name: REDIS_HOST
  value: {{ include "stackweaver.redis.host" . | quote }}
- name: REDIS_PORT
  value: {{ include "stackweaver.redis.port" . | quote }}
{{- if .Values.secrets.redis.secretName }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.secrets.redis.secretName }}
      key: {{ .Values.secrets.redis.keys.password }}
{{- end }}
{{- end }}

{{/*
Storage (MinIO/S3) env vars — for runner and ansible-runner.
*/}}
{{- define "stackweaver.env.storage" -}}
- name: STORAGE_ENDPOINT
  value: {{ include "stackweaver.minio.endpoint" . | quote }}
- name: STORAGE_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "stackweaver.secrets.minio" . }}
      key: {{ .Values.secrets.minio.keys.accessKey }}
- name: STORAGE_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "stackweaver.secrets.minio" . }}
      key: {{ .Values.secrets.minio.keys.secretKey }}
- name: STORAGE_USE_SSL
  value: {{ include "stackweaver.minio.useSSL" . | quote }}
{{- end }}

{{/*
Encryption key env var — shared between api, runner, ansible-runner.
*/}}
{{- define "stackweaver.env.encryption" -}}
- name: ENCRYPTION_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "stackweaver.secrets.encryption" . }}
      key: {{ .Values.secrets.encryption.keys.key }}
{{- end }}
