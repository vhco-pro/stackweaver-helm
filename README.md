# Stackweaver Helm Chart

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/vhco-pro/stackweaver-helm/badge)](https://scorecard.dev/viewer/?uri=github.com/vhco-pro/stackweaver-helm)

Helm chart for deploying [Stackweaver](https://sw.vhco.pro) on Kubernetes.

This is the public release repository for the Stackweaver Helm chart. It is published from the Stackweaver source tree on every release. See the [release sync architecture](https://sw.vhco.pro/docs/security/sync-architecture) for how releases are built, signed, and mirrored here.

## Installation

```shell
# Add the OCI registry (no separate helm repo add needed)
helm install stackweaver oci://ghcr.io/vhco-pro/charts/stackweaver --version 0.6.19

# Or with custom values
helm install stackweaver oci://ghcr.io/vhco-pro/charts/stackweaver \
  --version 0.6.19 \
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

The full verification guide including SBOM extraction, SLSA provenance (live after the Wave-6 visibility flip), and `gitsign verify` for sync commits lives at <https://sw.vhco.pro/docs/security/verifying-releases>.

## Trademark

Stackweaver™ is a trademark of VH & Co. The Stackweaver name and word mark identify the official Stackweaver project; the source-code licence does not grant a right to use the mark in product names, hosted services, or company names. See the [Trademark Policy](https://github.com/vhco-pro/.github/blob/main/TRADEMARK.md) for the full terms.

## License

Licensed under Apache 2.0  — see [LICENSE](LICENSE) for details.
