# Stackweaver Helm Chart

Helm chart for deploying [Stackweaver](https://github.com/vhco-pro/stackweaver) on Kubernetes.

> [!IMPORTANT]
> **This repository is auto-synced from the Stackweaver monorepo. Changes to the `chart` directory will be overwritten.**

## Installation

```shell
# Add the OCI registry (no separate helm repo add needed)
helm install stackweaver oci://ghcr.io/vhco-pro/charts/stackweaver --version 0.6.9

# Or with custom values
helm install stackweaver oci://ghcr.io/vhco-pro/charts/stackweaver \
  --version 0.6.9 \
  -f custom-values.yaml
```

## Configuration

See [values.yaml](chart/values.yaml) for all available configuration options.

## Verifying this Distribution

Chart versions **0.6.8 and later** are Sigstore-signed (keyless) and ship with an SPDX SBOM attestation. To verify a chart before installing:

```bash
cosign verify \
  --certificate-identity-regexp "^https://github\.com/vhco-pro/stackweaver-helm/\.github/workflows/release\.yml@refs/tags/.+$" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com" \
  ghcr.io/vhco-pro/charts/stackweaver:<chart-version>
```

The full verification guide — including SBOM extraction, SLSA provenance (live after the Wave-6 visibility flip), and `gitsign verify` for sync commits — lives at <https://sw.vhco.pro/docs/security/verifying-releases>.

## License

Licensed under Apache 2.0  — see [LICENSE](LICENSE) for details.
