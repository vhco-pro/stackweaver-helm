# Stackweaver Helm Chart

Helm chart for deploying [Stackweaver](https://sw.vhco.pro) on Kubernetes.

This is the public release repository for the Stackweaver Helm chart. It is published from the Stackweaver source tree on every release. See the [release sync architecture](https://sw.vhco.pro/docs/security/sync-architecture) for how releases are built, signed, and mirrored here.

## Installation

```shell
# Add the OCI registry (no separate helm repo add needed)
helm install stackweaver oci://ghcr.io/vhco-pro/charts/stackweaver --version 0.6.5

# Or with custom values
helm install stackweaver oci://ghcr.io/vhco-pro/charts/stackweaver \
  --version 0.6.5 \
  -f custom-values.yaml
```

## Configuration

See [values.yaml](chart/values.yaml) for all available configuration options.

## License

Licensed under Apache 2.0  — see [LICENSE](LICENSE) for details.
