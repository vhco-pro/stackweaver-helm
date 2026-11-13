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
PostgreSQL host, internal K8s DNS when bundled.
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
Storage endpoint, auto-resolve for bundled Garage, use values for external.
*/}}
{{- define "stackweaver.storage.endpoint" -}}
{{- if .Values.garage.enabled }}
{{- printf "%s-garage:3900" (include "stackweaver.fullname" .) }}
{{- else }}
{{- required "storage.endpoint is required when garage.enabled=false" .Values.storage.endpoint }}
{{- end }}
{{- end }}

{{/*
Garage layout capacity in bytes, derived from the PVC size so the capacity the node advertises
cannot drift from the disk it actually has. Accepts the Kubernetes quantity suffixes (Ki/Mi/Gi/Ti
and K/M/G/T); a bare number is treated as bytes.
*/}}
{{- define "stackweaver.garage.capacityBytes" -}}
{{- $size := .Values.garage.storage.size | toString -}}
{{- $bytes := 0 -}}
{{- if hasSuffix "Ti" $size -}}
{{- $bytes = mul (atoi (trimSuffix "Ti" $size)) 1099511627776 -}}
{{- else if hasSuffix "Gi" $size -}}
{{- $bytes = mul (atoi (trimSuffix "Gi" $size)) 1073741824 -}}
{{- else if hasSuffix "Mi" $size -}}
{{- $bytes = mul (atoi (trimSuffix "Mi" $size)) 1048576 -}}
{{- else if hasSuffix "Ki" $size -}}
{{- $bytes = mul (atoi (trimSuffix "Ki" $size)) 1024 -}}
{{- else if hasSuffix "T" $size -}}
{{- $bytes = mul (atoi (trimSuffix "T" $size)) 1000000000000 -}}
{{- else if hasSuffix "G" $size -}}
{{- $bytes = mul (atoi (trimSuffix "G" $size)) 1000000000 -}}
{{- else if hasSuffix "M" $size -}}
{{- $bytes = mul (atoi (trimSuffix "M" $size)) 1000000 -}}
{{- else if hasSuffix "K" $size -}}
{{- $bytes = mul (atoi (trimSuffix "K" $size)) 1000 -}}
{{- else -}}
{{- $bytes = atoi $size -}}
{{- end -}}
{{- if le (int64 $bytes) 0 -}}
{{- fail (printf "garage.storage.size %q could not be parsed into a byte count for the cluster layout" $size) -}}
{{- end -}}
{{- $bytes -}}
{{- end }}

{{/*
Storage useSSL, false for bundled Garage, configurable for external.
*/}}
{{- define "stackweaver.storage.useSSL" -}}
{{- if .Values.garage.enabled }}
{{- false }}
{{- else }}
{{- .Values.storage.useSSL | default false }}
{{- end }}
{{- end }}

{{/*
Storage forcePathStyle, true for bundled Garage, configurable for external.
*/}}
{{- define "stackweaver.storage.forcePathStyle" -}}
{{- if .Values.garage.enabled }}
{{- true }}
{{- else }}
{{- .Values.storage.forcePathStyle | default false }}
{{- end }}
{{- end }}

{{/*
Storage region, "garage" for bundled, configurable for external.
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
{{- .Values.secrets.oidc.secretName | default (printf "%s-oidc" (include "stackweaver.fullname" .)) }}
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
Zitadel external issuer URL (browser-reachable). Used by the backend for OIDC
iss-claim validation and surfaced in NOTES; the SPA does no client-side iss
validation, so this is not injected into the frontend env.js.
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
Points at the Stackweaver SPA's /login routes, the custom login UI that replaced
the standalone zitadel-login container. Override via zitadel.config.loginUIBaseURL
if the SPA is served from a non-default location.
*/}}
{{- define "stackweaver.loginUI.baseURL" -}}
{{- if .Values.zitadel.config.loginUIBaseURL }}
{{- .Values.zitadel.config.loginUIBaseURL }}
{{- else }}
{{- printf "%s/login" (include "stackweaver.app.url" .) }}
{{- end }}
{{- end }}

{{/*
Login UI external origin (scheme://host[:port], no path).
Used for CORS-adjacent configuration that expects an origin, not a full URL.
*/}}
{{- define "stackweaver.loginUI.origin" -}}
{{- if .Values.zitadel.config.loginUIBaseURL }}
{{- .Values.zitadel.config.loginUIBaseURL | trimSuffix "/login" }}
{{- else }}
{{- include "stackweaver.app.url" . }}
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
Where Zitadel returns the browser after sign-in: the SPA's callback page, whose code the API
redeems as the confidential BFF client.
*/}}
{{- define "stackweaver.signInRedirectURI" -}}
{{- printf "%s/auth/callback" (include "stackweaver.app.url" .) }}
{{- end }}

{{/* ── Ingress annotation helpers ─────────────────────────────────────── */}}

{{/*
App ingress annotations, provider presets + global + per-ingress overrides.
Usage: {{- include "stackweaver.ingress.appAnnotations" . | nindent 4 }}
*/}}
{{- define "stackweaver.ingress.appAnnotations" -}}
{{- if eq .Values.ingress.provider "community-nginx" }}
nginx.ingress.kubernetes.io/use-regex: "true"
nginx.ingress.kubernetes.io/proxy-body-size: "100m"
nginx.ingress.kubernetes.io/proxy-read-timeout: "3600"
nginx.ingress.kubernetes.io/proxy-send-timeout: "3600"
{{- else if eq .Values.ingress.provider "nginx-inc" }}
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
Auth ingress annotations, provider presets + global + per-ingress overrides.
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
Database env vars, shared between api, orchestrator, runner, ansible-runner.
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
Redis env vars, shared between api, orchestrator, runner, ansible-runner.
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
Storage env vars, injected into api, runner, ansible-runner, orchestrator.
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
Encryption key env var, shared between api, runner, ansible-runner.
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
Volume definition for the custom CA, emits nothing when disabled.
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
VolumeMount for the custom CA, emits nothing when disabled.
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

{{/*
Whether the secrets-init bootstrap hook is needed at all.

Emits "true" when at least one Secret is chart-managed, i.e. the user has not
supplied a secretName for it (and, for storage, credential auth is in use).
When every secret is brought by the user, neither the Job nor its RBAC is
rendered - that makes bring-your-own an airtight, zero-image-dependency install
path for air-gapped clusters, not just a "the Job will no-op" promise.
*/}}
{{- define "stackweaver.secretsInit.needed" -}}
{{- $needed := false -}}
{{- if not .Values.secrets.postgresql.secretName }}{{- $needed = true -}}{{- end }}
{{- if and (not .Values.secrets.storage.secretName) (eq (.Values.storage.auth | default "credentials") "credentials") }}{{- $needed = true -}}{{- end }}
{{- if .Values.garage.enabled }}{{- $needed = true -}}{{- end }}
{{- if not .Values.secrets.encryption.secretName }}{{- $needed = true -}}{{- end }}
{{- if not .Values.secrets.zitadel.secretName }}{{- $needed = true -}}{{- end }}
{{- if not .Values.secrets.oidc.secretName }}{{- $needed = true -}}{{- end }}
{{- if not .Values.secrets.hosted.secretName }}{{- $needed = true -}}{{- end }}
{{- if $needed }}true{{- end }}
{{- end }}

{{/* Trusted public-site settings. The URL belongs to the operator, never to request headers. */}}
{{- define "stackweaver.publicSite.values" -}}
{{- $site := trimSuffix "/" (.Values.frontend.publicSite.url | default "") -}}
{{- $indexing := .Values.frontend.publicSite.indexing | default false -}}
{{- if and $indexing (not $site) }}{{ fail "Public indexing requires an explicit public site URL" }}{{ end -}}
{{- if and $site (not (regexMatch `^https://[A-Za-z0-9.-]+(:[0-9]+)?(/[A-Za-z0-9_-]+)*$` $site)) }}{{ fail "Public site URL must be an HTTPS origin with an optional clean base path" }}{{ end -}}
{{- $base := regexReplaceAll `^https://[^/]+` $site "" -}}
{{- dict "url" $site "basePath" $base "indexing" $indexing | toJson -}}
{{- end -}}

{{- define "stackweaver.publicSite.settings" -}}
{{- $site := include "stackweaver.publicSite.values" . | fromJson -}}
# Generated deployment settings. Mount at /etc/nginx/public-site-settings.conf.
set $sw_site_url {{ $site.url | quote }};
set $sw_contact_opt_in "0";
set $sw_base_path {{ $site.basePath | quote }};
set $sw_noindex {{ ternary "" "noindex, nofollow" $site.indexing | quote }};
set $sw_sitemap_line {{ ternary (printf "Sitemap: %s/sitemap.xml" $site.url) "" $site.indexing | quote }};
{{ if $site.basePath -}}
if ($uri = {{ $site.basePath | quote }}) { return 308 {{ $site.basePath }}/; }
rewrite ^{{ $site.basePath }}(/.*)$ $1 last;
{{ end -}}
{{- end -}}

{{/* ── Launchers (#933) ─────────────────────────────────────────────── */}}

{{- define "stackweaver.secrets.hosted" -}}
{{- .Values.secrets.hosted.secretName | default (printf "%s-hosted" (include "stackweaver.fullname" .)) }}
{{- end }}

{{/* The launchers' own ServiceAccount, bound to the namespaced Role over the job namespace. */}}
{{- define "stackweaver.launcher.serviceAccountName" -}}
{{- printf "%s-launcher" (include "stackweaver.fullname" .) }}
{{- end }}

{{/* The namespace job pods run in: launcher.jobNamespace, else the release's. */}}
{{- define "stackweaver.launcher.jobNamespace" -}}
{{- .Values.launcher.jobNamespace | default .Release.Namespace }}
{{- end }}

{{/*
The launcher's values, as YAML for fromYaml: image, replicas, maxConcurrentJobs, resources, env,
runEnvPassthrough, podAnnotations, nodeSelector, tolerations, affinity and jobImages. For two minor
releases the runner.* and ansibleRunner.* values of the two-launcher chart are translated onto them
(one-launcher spec, A7, OD6), and NOTES.txt lists each one (stackweaver.launcher.legacyKeys):
runner.image and ansibleRunner.image feed the job images and their pullPolicy the launcher image's,
env, runEnvPassthrough, podAnnotations, nodeSelector and tolerations merge into the launcher's, the
larger replicas and the summed maxConcurrentJobs apply (an unset one at its old default 4), and an
old resources or affinity replaces the launcher's.
*/}}
{{- define "stackweaver.launcher.values" -}}
{{- $l := .Values.launcher -}}
{{- $r := .Values.runner | default dict -}}
{{- $a := .Values.ansibleRunner | default dict -}}
{{- $ri := $r.image | default dict -}}
{{- $ai := $a.image | default dict -}}
{{- $jobImages := dict
      "opentofu" (merge (pick $ri "repository" "tag") (deepCopy $l.jobImages.opentofu))
      "ansible" (merge (pick $ai "repository" "tag") (deepCopy $l.jobImages.ansible)) -}}
{{- $image := merge (dict "pullPolicy" ($ri.pullPolicy | default $ai.pullPolicy | default $l.image.pullPolicy)) (deepCopy $l.image) -}}
{{- $replicas := max ($l.replicas | int) ($r.replicas | default 0 | int) ($a.replicas | default 0 | int) -}}
{{- $jobs := $l.maxConcurrentJobs | int -}}
{{- if or (hasKey $r "maxConcurrentJobs") (hasKey $a "maxConcurrentJobs") }}
{{- $jobs = add ($r.maxConcurrentJobs | default 4 | int) ($a.maxConcurrentJobs | default 4 | int) -}}
{{- end }}
{{- dict
      "image" $image
      "replicas" $replicas
      "maxConcurrentJobs" $jobs
      "resources" ($r.resources | default $a.resources | default $l.resources)
      "env" (merge (deepCopy ($l.env | default dict)) ($r.env | default dict) ($a.env | default dict))
      "runEnvPassthrough" (concat ($l.runEnvPassthrough | default list) ($r.runEnvPassthrough | default list) ($a.runEnvPassthrough | default list) | uniq)
      "podAnnotations" (merge (deepCopy ($l.podAnnotations | default dict)) ($r.podAnnotations | default dict) ($a.podAnnotations | default dict))
      "nodeSelector" (merge (deepCopy ($l.nodeSelector | default dict)) ($r.nodeSelector | default dict) ($a.nodeSelector | default dict))
      "tolerations" (concat ($l.tolerations | default list) ($r.tolerations | default list) ($a.tolerations | default list))
      "affinity" ($r.affinity | default $a.affinity | default $l.affinity | default dict)
      "jobImages" $jobImages
    | toYaml }}
{{- end }}

{{/*
The runner.* and ansibleRunner.* values a release still sets, one line each with where it went,
for NOTES.txt (OD6); empty when it sets none.
*/}}
{{- define "stackweaver.launcher.legacyKeys" -}}
{{- $to := dict
      "image.repository" "launcher.jobImages.%s.repository"
      "image.tag" "launcher.jobImages.%s.tag"
      "image.pullPolicy" "launcher.image.pullPolicy"
      "replicas" "launcher.replicas (the larger applies)"
      "maxConcurrentJobs" "launcher.maxConcurrentJobs (the two are summed)"
      "resources" "launcher.resources"
      "env" "launcher.env (merged)"
      "runEnvPassthrough" "launcher.runEnvPassthrough (merged)"
      "podAnnotations" "launcher.podAnnotations (merged)"
      "nodeSelector" "launcher.nodeSelector (merged)"
      "tolerations" "launcher.tolerations (appended)"
      "affinity" "launcher.affinity" -}}
{{- range $old, $engine := dict "runner" "opentofu" "ansibleRunner" "ansible" }}
{{- $vals := get $.Values $old | default dict }}
{{- range $key := keys $vals | sortAlpha }}
{{- $v := get $vals $key }}
{{- $subkeys := list $key }}
{{- if and (eq $key "image") (kindIs "map" $v) }}
{{- $subkeys = list }}
{{- range $sub := keys $v | sortAlpha }}
{{- $subkeys = append $subkeys (printf "image.%s" $sub) }}
{{- end }}
{{- end }}
{{- range $subkeys }}
{{- if hasKey $to . }}
{{- $dest := get $to . }}
  {{ $old }}.{{ . }} -> {{ ternary (printf $dest $engine) $dest (contains "%s" $dest) }}
{{- else }}
  {{ $old }}.{{ . }} -> not translated; remove it
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/* A launcher's extra environment (launcher.env) and its passthrough list, given its values. */}}
{{- define "stackweaver.launcher.extraEnv" -}}
# ── Extra env vars (user overrides) ──
{{- range $key, $value := .env }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
# ── Launcher variables handed to jobs beyond the built-in allowlist ──
{{- with .runEnvPassthrough }}
- name: STACKWEAVER_RUN_ENV_PASSTHROUGH
  value: {{ join "," . | quote }}
{{- end }}
{{- end }}

{{/* launcher.jobImages.pullPolicy as RUNNER_JOB_IMAGE_PULL (OD18). */}}
{{- define "stackweaver.launcher.jobImagePull" -}}
{{- $p := .Values.launcher.jobImages.pullPolicy | default "Always" -}}
{{- $m := dict "Always" "always" "IfNotPresent" "missing" "Never" "never" -}}
{{- if not (hasKey $m $p) }}
{{- fail (printf "launcher.jobImages.pullPolicy=%s is not Always, IfNotPresent or Never" $p) }}
{{- end }}
{{- get $m $p }}
{{- end }}

{{/* The names of the dockerconfigjson Secrets the launcher pulls job images with, as a JSON list:
launcher.jobImages.pullSecrets, else global.imagePullSecrets (OD19, OD26). */}}
{{- define "stackweaver.launcher.registryAuth.secrets" -}}
{{- $names := list -}}
{{- range (.Values.launcher.jobImages.pullSecrets | default .Values.global.imagePullSecrets) }}
{{- if kindIs "string" . }}
{{- $names = append $names . }}
{{- else }}
{{- $names = append $names .name }}
{{- end }}
{{- end }}
{{- $names | toJson }}
{{- end }}

{{/* Where the launcher reads its registry credential: one file per Secret (RUNNER_DOCKER_CONFIG). */}}
{{- define "stackweaver.launcher.registryAuth.path" -}}/etc/stackweaver/registry-auth{{- end }}

{{- define "stackweaver.launcher.registryAuth.volume" -}}
{{- $names := include "stackweaver.launcher.registryAuth.secrets" . | fromJsonArray }}
{{- if $names }}
- name: registry-auth
  projected:
    sources:
      {{- range $names }}
      - secret:
          name: {{ . }}
          items:
            - key: .dockerconfigjson
              path: {{ . }}.json
      {{- end }}
{{- end }}
{{- end }}

{{- define "stackweaver.launcher.registryAuth.volumeMount" -}}
{{- if include "stackweaver.launcher.registryAuth.secrets" . | fromJsonArray }}
- name: registry-auth
  mountPath: {{ include "stackweaver.launcher.registryAuth.path" . }}
  readOnly: true
{{- end }}
{{- end }}

{{/*
The environment every launcher shares: the API it registers with as the deployment's hosted
launcher, the hosted secret, and where and how it places job pods. No database, storage,
Redis, encryption, OIDC signing or VCS app secret: the executor in each job pod fetches what its
job needs from the API with a token for that job alone (AC1).
*/}}
{{- define "stackweaver.env.launcher" -}}
{{- $l := include "stackweaver.launcher.values" . | fromYaml }}
- name: STACKWEAVER_SERVER
  {{- /* Namespace-qualified: job pods in launcher.jobNamespace reach the API on this address too. */}}
  value: {{ printf "http://%s-api.%s.svc:%v" (include "stackweaver.fullname" .) .Release.Namespace .Values.api.port | quote }}
- name: STACKWEAVER_HOSTED
  value: "1"
- name: STACKWEAVER_HOSTED_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "stackweaver.secrets.hosted" . }}
      key: {{ .Values.secrets.hosted.keys.secret }}
{{- if .Values.launcher.hostedGroup }}
- name: STACKWEAVER_HOSTED_GROUP
  value: {{ .Values.launcher.hostedGroup | quote }}
{{- end }}
{{- if .Values.launcher.hostedStrict }}
- name: STACKWEAVER_HOSTED_STRICT
  value: "1"
{{- end }}
- name: RUNNER_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: RUNNER_DRIVER
  value: {{ .Values.launcher.driver | quote }}
{{- /* Each engine's jobs run in that engine's job image (one-launcher spec, A3). */}}
- name: RUNNER_TOFU_IMAGE
  value: "{{ $l.jobImages.opentofu.repository }}:{{ $l.jobImages.opentofu.tag }}"
- name: RUNNER_ANSIBLE_IMAGE
  value: "{{ $l.jobImages.ansible.repository }}:{{ $l.jobImages.ansible.tag }}"
- name: RUNNER_JOB_IMAGE_PULL
  value: {{ include "stackweaver.launcher.jobImagePull" . | quote }}
{{- if include "stackweaver.launcher.registryAuth.secrets" . | fromJsonArray }}
- name: RUNNER_DOCKER_CONFIG
  value: {{ include "stackweaver.launcher.registryAuth.path" . | quote }}
{{- end }}
- name: RUNNER_NETWORK_MODE
  value: {{ .Values.launcher.network | quote }}
- name: RUNNER_JOB_NAMESPACE
  value: {{ include "stackweaver.launcher.jobNamespace" . | quote }}
- name: RUNNER_POD_TEMPLATE_CONFIGMAP
  value: {{ printf "%s-launcher-pod-template" (include "stackweaver.fullname" .) | quote }}
- name: RUNNER_MANAGE_NETWORK_POLICY
  value: "false"
{{- with .Values.launcher.runtimeClassName }}
- name: RUNNER_RUNTIME_CLASS
  value: {{ . | quote }}
{{- end }}
{{- with .Values.launcher.jobUID }}
- name: RUNNER_JOB_UID
  value: {{ . | quote }}
{{- end }}
{{- with .Values.launcher.keepFailedJobsFor }}
- name: RUNNER_KEEP_FAILED_FOR
  value: {{ . | quote }}
{{- end }}
- name: RUNNER_HEALTH_ADDR
  value: {{ printf ":%v" .Values.launcher.healthPort | quote }}
- name: HOME
  value: /tmp
{{- end }}

{{/* The probes every launcher carries (AC75). */}}
{{- define "stackweaver.launcher.probes" -}}
livenessProbe:
  httpGet:
    path: /healthz
    port: health
  periodSeconds: 20
  failureThreshold: 3
readinessProbe:
  httpGet:
    path: /readyz
    port: health
  periodSeconds: 10
  failureThreshold: 6
{{- end }}

{{/*
A launcher Deployment, given a dict: root (the chart's context), name, engine (the in-process
engine label, empty for the Kubernetes-driver launcher), engines (RUNNER_ENGINES, or empty), image,
pullPolicy, tmpSize, and values (stackweaver.launcher.values, with any per-engine overrides).
*/}}
{{- define "stackweaver.launcher.deployment" -}}
{{- $root := .root }}
{{- $l := .values }}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .name }}
  labels:
    {{- include "stackweaver.labels" $root | nindent 4 }}
    app.kubernetes.io/component: launcher
    {{- with .engine }}
    stackweaver.io/launcher-engine: {{ . }}
    {{- end }}
spec:
  replicas: {{ $l.replicas }}
  selector:
    matchLabels:
      {{- include "stackweaver.selectorLabels" $root | nindent 6 }}
      app.kubernetes.io/component: launcher
      {{- with .engine }}
      stackweaver.io/launcher-engine: {{ . }}
      {{- end }}
  template:
    metadata:
      labels:
        {{- include "stackweaver.selectorLabels" $root | nindent 8 }}
        app.kubernetes.io/component: launcher
        {{- with .engine }}
        stackweaver.io/launcher-engine: {{ . }}
        {{- end }}
      {{- with $l.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
    spec:
      {{- include "stackweaver.imagePullSecrets" $root | nindent 6 }}
      serviceAccountName: {{ include "stackweaver.launcher.serviceAccountName" $root }}
      # Outlasts the launcher's drain, so a rollout lets its jobs finish (launcher.terminationGracePeriodSeconds).
      terminationGracePeriodSeconds: {{ $root.Values.launcher.terminationGracePeriodSeconds }}
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: launcher
          image: {{ .image | quote }}
          imagePullPolicy: {{ .pullPolicy }}
          securityContext:
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
          ports:
            - name: health
              containerPort: {{ $root.Values.launcher.healthPort }}
          env:
            - name: LOG_LEVEL
              value: info
            {{- include "stackweaver.env.launcher" $root | nindent 12 }}
            {{- with .engines }}
            # The engine this launcher's toolchain serves (OD11).
            - name: RUNNER_ENGINES
              value: {{ . | quote }}
            {{- end }}
            - name: RUNNER_MAX_CONCURRENT_JOBS
              value: {{ $l.maxConcurrentJobs | quote }}
            {{- include "stackweaver.launcher.extraEnv" $l | nindent 12 }}
          {{- include "stackweaver.launcher.probes" $root | nindent 10 }}
          volumeMounts:
            - name: tmp
              mountPath: /tmp
            {{- include "stackweaver.launcher.registryAuth.volumeMount" $root | nindent 12 }}
            {{- include "stackweaver.customCA.volumeMount" $root | nindent 12 }}
          resources:
            {{- toYaml $l.resources | nindent 12 }}
      volumes:
        - name: tmp
          emptyDir:
            sizeLimit: {{ .tmpSize }}
        {{- include "stackweaver.launcher.registryAuth.volume" $root | nindent 8 }}
        {{- include "stackweaver.customCA.volume" $root | nindent 8 }}
      {{- with $l.nodeSelector }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $l.affinity }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with $l.tolerations }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
