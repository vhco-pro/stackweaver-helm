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
Storage endpoint — auto-resolve for bundled Garage, use values for external.
*/}}
{{- define "stackweaver.storage.endpoint" -}}
{{- if .Values.garage.enabled }}
{{- printf "%s-garage:3900" (include "stackweaver.fullname" .) }}
{{- else }}
{{- required "storage.endpoint is required when garage.enabled=false" .Values.storage.endpoint }}
{{- end }}
{{- end }}

{{/*
Storage useSSL — false for bundled Garage, configurable for external.
*/}}
{{- define "stackweaver.storage.useSSL" -}}
{{- if .Values.garage.enabled }}
{{- false }}
{{- else }}
{{- .Values.storage.useSSL | default false }}
{{- end }}
{{- end }}

{{/*
Storage forcePathStyle — true for bundled Garage, configurable for external.
*/}}
{{- define "stackweaver.storage.forcePathStyle" -}}
{{- if .Values.garage.enabled }}
{{- true }}
{{- else }}
{{- .Values.storage.forcePathStyle | default false }}
{{- end }}
{{- end }}

{{/*
Storage region — "garage" for bundled, configurable for external.
*/}}
{{- define "stackweaver.storage.region" -}}
{{- if .Values.garage.enabled }}
{{- "garage" }}
{{- else }}
{{- .Values.storage.region | default "us-east-1" }}
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

{{- define "stackweaver.secrets.storage" -}}
{{- .Values.secrets.storage.secretName | default (printf "%s-storage" (include "stackweaver.fullname" .)) }}
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
{{- if (index .Values.frontend.env "VITE_ZITADEL_ISSUER") }}
{{- index .Values.frontend.env "VITE_ZITADEL_ISSUER" }}
{{- else if .Values.zitadel.bundled }}
{{- $scheme := ternary "https" "http" .Values.ingress.tls.enabled }}
{{- printf "%s://%s" $scheme .Values.ingress.hosts.auth }}
{{- else }}
{{- required "zitadel.external.issuer is required when zitadel.bundled=false" .Values.zitadel.external.issuer }}
{{- end }}
{{- end }}

{{/*
Login UI external base URL (browser-reachable).
With an ingress, the login UI shares Zitadel's domain (path-based routing).
Without an ingress (e.g. kind), set zitadel.config.loginUIBaseURL to the
browser-reachable URL of the login-ui container (e.g. http://localhost:3000/ui/v2/login).
*/}}
{{- define "stackweaver.loginUI.baseURL" -}}
{{- if .Values.zitadel.config.loginUIBaseURL }}
{{- .Values.zitadel.config.loginUIBaseURL }}
{{- else if .Values.zitadel.config.ExternalDomain }}
{{- $scheme := ternary "https" "http" (hasKey .Values.zitadel.config "ExternalSecure" | ternary .Values.zitadel.config.ExternalSecure .Values.ingress.tls.enabled) }}
{{- $port := .Values.zitadel.config.ExternalPort | default (ternary 443 80 .Values.ingress.tls.enabled) }}
{{- if or (and (eq $scheme "https") (eq (int $port) 443)) (and (eq $scheme "http") (eq (int $port) 80)) }}
{{- printf "%s://%s/ui/v2/login" $scheme .Values.zitadel.config.ExternalDomain }}
{{- else }}
{{- printf "%s://%s:%v/ui/v2/login" $scheme .Values.zitadel.config.ExternalDomain $port }}
{{- end }}
{{- else }}
{{- $scheme := ternary "https" "http" .Values.ingress.tls.enabled }}
{{- printf "%s://%s/ui/v2/login" $scheme .Values.ingress.hosts.auth }}
{{- end }}
{{- end }}

{{/*
Login UI external origin.
Derives from loginUIBaseURL if set, otherwise from ExternalDomain or ingress host.
*/}}
{{- define "stackweaver.loginUI.origin" -}}
{{- if .Values.zitadel.config.loginUIBaseURL }}
{{- /* Extract origin (scheme://host:port) from the full BaseURL */ -}}
{{- .Values.zitadel.config.loginUIBaseURL | trimSuffix "/ui/v2/login" }}
{{- else if .Values.zitadel.config.ExternalDomain }}
{{- $scheme := ternary "https" "http" (hasKey .Values.zitadel.config "ExternalSecure" | ternary .Values.zitadel.config.ExternalSecure .Values.ingress.tls.enabled) }}
{{- $port := .Values.zitadel.config.ExternalPort | default (ternary 443 80 .Values.ingress.tls.enabled) }}
{{- if or (and (eq $scheme "https") (eq (int $port) 443)) (and (eq $scheme "http") (eq (int $port) 80)) }}
{{- printf "%s://%s" $scheme .Values.zitadel.config.ExternalDomain }}
{{- else }}
{{- printf "%s://%s:%v" $scheme .Values.zitadel.config.ExternalDomain $port }}
{{- end }}
{{- else }}
{{- $scheme := ternary "https" "http" .Values.ingress.tls.enabled }}
{{- printf "%s://%s" $scheme .Values.ingress.hosts.auth }}
{{- end }}
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
{{- if (index .Values.frontend.env "VITE_API_URL") }}
{{- index .Values.frontend.env "VITE_API_URL" }}
{{- else }}
{{- printf "%s/api/v2" (include "stackweaver.app.url" .) }}
{{- end }}
{{- end }}

{{/*
Frontend OIDC redirect URI.
*/}}
{{- define "stackweaver.frontend.redirectURI" -}}
{{- if (index .Values.frontend.env "VITE_ZITADEL_REDIRECT_URI") }}
{{- index .Values.frontend.env "VITE_ZITADEL_REDIRECT_URI" }}
{{- else }}
{{- printf "%s/auth/callback" (include "stackweaver.app.url" .) }}
{{- end }}
{{- end }}

{{/* ── Ingress annotation helpers ─────────────────────────────────────── */}}

{{/*
App ingress annotations — provider presets + global + per-ingress overrides.
Usage: {{- include "stackweaver.ingress.appAnnotations" . | nindent 4 }}
*/}}
{{- define "stackweaver.ingress.appAnnotations" -}}
{{- if eq .Values.ingress.provider "community-nginx" }}
nginx.ingress.kubernetes.io/use-regex: "true"
nginx.ingress.kubernetes.io/proxy-body-size: "100m"
nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
{{- else if eq .Values.ingress.provider "nginx-inc" }}
nginx.org/path-regex: "case_sensitive"
nginx.org/client-max-body-size: "100m"
nginx.org/proxy-read-timeout: "3600s"
nginx.org/proxy-send-timeout: "3600s"
{{- else if eq .Values.ingress.provider "traefik" }}
{{- /* Traefik uses middleware CRDs for timeouts and body size; no annotations needed */}}
{{- end }}
{{- with .Values.ingress.annotations }}
{{ toYaml . }}
{{- end }}
{{- with .Values.ingress.appAnnotations }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Auth ingress annotations — provider presets + global + per-ingress overrides.
Usage: {{- include "stackweaver.ingress.authAnnotations" . | nindent 4 }}
*/}}
{{- define "stackweaver.ingress.authAnnotations" -}}
{{- if eq .Values.ingress.provider "community-nginx" }}
nginx.ingress.kubernetes.io/use-regex: "true"
nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
nginx.ingress.kubernetes.io/proxy-body-size: "10m"
{{- else if eq .Values.ingress.provider "nginx-inc" }}
nginx.org/path-regex: "case_sensitive"
nginx.org/client-max-body-size: "10m"
{{- else if eq .Values.ingress.provider "traefik" }}
{{- /* Traefik uses middleware CRDs; no annotations needed */}}
{{- end }}
{{- with .Values.ingress.annotations }}
{{ toYaml . }}
{{- end }}
{{- with .Values.ingress.authAnnotations }}
{{ toYaml . }}
{{- end }}
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
Storage env vars — injected into api, runner, ansible-runner, orchestrator.
Single block, works for both bundled Garage and any external S3 service.
When storage.auth=pod-identity, credential env vars are omitted.
*/}}
{{- define "stackweaver.env.storage" -}}
- name: STORAGE_BACKEND
  value: "s3"
- name: STORAGE_ENDPOINT
  value: {{ include "stackweaver.storage.endpoint" . | quote }}
{{- if eq (.Values.storage.auth | default "credentials") "credentials" }}
- name: STORAGE_ACCESS_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "stackweaver.secrets.storage" . }}
      key: {{ .Values.secrets.storage.keys.accessKey }}
- name: STORAGE_SECRET_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "stackweaver.secrets.storage" . }}
      key: {{ .Values.secrets.storage.keys.secretKey }}
{{- end }}
- name: STORAGE_USE_SSL
  value: {{ include "stackweaver.storage.useSSL" . | quote }}
- name: STORAGE_BUCKET
  value: {{ .Values.storage.bucket | quote }}
- name: STORAGE_REGION
  value: {{ include "stackweaver.storage.region" . | quote }}
- name: STORAGE_FORCE_PATH_STYLE
  value: {{ include "stackweaver.storage.forcePathStyle" . | quote }}
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

{{/* ── Custom CA certificate helpers ──────────────────────────────────── */}}

{{/*
Returns a non-empty string when any custom CA source is configured.
Use as a truthy check: {{- if include "stackweaver.customCA.enabled" . }}
*/}}
{{- define "stackweaver.customCA.enabled" -}}
{{- if or .Values.customCA.existingSecret .Values.customCA.existingConfigMap .Values.customCA.cert }}true{{- end }}
{{- end }}

{{/*
Volume definition for the custom CA — emits nothing when disabled.
Include with nindent inside a volumes: list.
*/}}
{{- define "stackweaver.customCA.volume" -}}
{{- if .Values.customCA.existingSecret }}
- name: custom-ca
  secret:
    secretName: {{ .Values.customCA.existingSecret }}
{{- else if .Values.customCA.existingConfigMap }}
- name: custom-ca
  configMap:
    name: {{ .Values.customCA.existingConfigMap }}
{{- else if .Values.customCA.cert }}
- name: custom-ca
  configMap:
    name: {{ include "stackweaver.fullname" . }}-custom-ca
{{- end }}
{{- end }}

{{/*
VolumeMount for the custom CA — emits nothing when disabled.
Mounted at /etc/ssl/certs/custom-ca.crt via subPath so the system cert
directory is not replaced. Go's crypto/x509 scans /etc/ssl/certs/ on Linux.
Include with nindent inside a volumeMounts: list.
*/}}
{{- define "stackweaver.customCA.volumeMount" -}}
{{- if include "stackweaver.customCA.enabled" . }}
- name: custom-ca
  mountPath: /etc/ssl/certs/custom-ca.crt
  subPath: {{ .Values.customCA.key | default "ca.crt" }}
  readOnly: true
{{- end }}
{{- end }}
