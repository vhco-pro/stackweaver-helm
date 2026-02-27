# Stackweaver Helm Chart

Helm chart for deploying [Stackweaver](https://github.com/vhco-pro/stackweaver) on Kubernetes.

> **This repository is auto-synced from the Stackweaver monorepo. Do not make changes here directly.**

## Installation

```bash
# Add the OCI registry (no separate helm repo add needed)
helm install stackweaver oci://ghcr.io/vhco-pro/charts/stackweaver --version 1.0.0

# Or with custom values
helm install stackweaver oci://ghcr.io/vhco-pro/charts/stackweaver \
  --version 1.0.0 \
  -f custom-values.yaml
```

## Configuration

See [values.yaml](chart/values.yaml) for all available configuration options.

## License

Business Source License 1.1 — see [LICENSE](LICENSE) for details.
