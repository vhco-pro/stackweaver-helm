# Stackweaver Helm Chart

Helm chart for deploying [Stackweaver](https://github.com/vhco-pro/stackweaver) on Kubernetes.

> [!IMPORTANT]
> **This repository is auto-synced from the Stackweaver monorepo. Changes to the `chart` directory will be overwritten.**

## Installation

```shell
# Add the OCI registry (no separate helm repo add needed)
helm install stackweaver oci://ghcr.io/vhco-pro/charts/stackweaver --version 0.3.14

# Or with custom values
helm install stackweaver oci://ghcr.io/vhco-pro/charts/stackweaver \
  --version 0.3.14 \
  -f custom-values.yaml
```

## Configuration

See [values.yaml](chart/values.yaml) for all available configuration options.

## License

Licensed under Apache 2.0  — see [LICENSE](LICENSE) for details.
