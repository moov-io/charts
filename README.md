## moov-io/charts

[![Build Status](https://travis-ci.com/moov-io/ach.svg?branch=master)](https://travis-ci.com/moov-io/ach)
[![Apache 2 licensed](https://img.shields.io/badge/license-Apache2-blue.svg)](https://raw.githubusercontent.com/moov-io/ach/master/LICENSE)

Kubernetes Helm Charts for the Moov ecosystem. All charts are in incubation phase and are expected to change in the near future.

### Install / Usage

To test a chart locally without applying it to kubernetes, do:

```
$ cd stable/ach/
$ helm install --debug --dry-run .
```

#### OpenShift Images

We host images for OpenShift built from their Universal Base Image (UBI) on Quay.io for download.

| Service | Docker Hub | Quay.io |
|-----|------|-----|
| moov-io/ach | `moov/ach` | `quay.io/moov/ach` |
| moov-io/fed | `moov/fed` | `quay.io/moov/fed` |
| moov-io/imagecashletter | `moov/imagecashletter` | `quay.io/moov/imagecashletter` |
| moov-io/watchman | `moov/watchman` | `quay.io/moov/watchman` |
| moov-io/wire | `moov/wire` | `quay.io/moov/wire` |

This would mean calling `helm install` with the following override `--set image.repository=quay.io/moov/ach` for ACH.

### Testing

To run included tests run:

```
# Lint all charts, render templates, and lint the Kubernetes manifests with kubeval
$ make test
...
wrote /var/folders/k3/pby7w8cn6xs_l3lrhz54vw5r0000gn/T/tmp.3MaxRFw9/ach/templates/deployment.yaml
...
PASS - ach/templates/deployment.yaml contains a valid Deployment
```

#### Integration testing

We use [Kind](https://github.com/kubernetes-sigs/kind) (Kubernetes IN Docker) to launch a cluster where the helm charts are installed into.

```
# Integration testing
$ make integration-setup

# Test either Docker Hub or Quay.io images
$ make integration-docker-hub
$ make integration-openshift

# Cleanup test cluster
$ make integration-destroy
```

Note: To rapidly test changes to a chart use `make integration-cleanup` between test runs.

### Getting Help

 channel | info
 ------- | -------
Twitter [@moov](https://twitter.com/moov)	| You can follow Moov.io's Twitter feed to get updates on our project(s). You can also tweet us questions or just share blogs or stories.
[GitHub Issue](https://github.com/moov-io/charts/issues) | If you are able to reproduce a problem please open a GitHub Issue under the specific project that caused the error.
[moov-io slack](https://slack.moov.io/) | Join our slack channel to have an interactive discussion about the development of the project.

### Contributing

Yes please! Please review our [Contributing guide](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md) to get started!

### License

Apache License 2.0 See [LICENSE](LICENSE) for details.
