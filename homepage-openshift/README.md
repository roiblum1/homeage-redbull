# Homepage Helm Chart - Baked Image Only

Simple, streamlined Helm chart for deploying Homepage with **baked-in configuration**.

## Overview

This chart deploys Homepage using a **custom-built container image** that contains:
- ✅ All configuration files (services, settings, widgets, bookmarks)
- ✅ Custom icons (GitLab, ArgoCD, OpenShift, etc.)
- ✅ Background images
- ✅ Environment variables for air-gapped environments

**No ConfigMaps. No complexity. Just deploy.**

## Prerequisites

- OpenShift 4.x or Kubernetes 1.19+
- Helm 3.x
- Custom Homepage image built and pushed to registry

## Building the Custom Image

Before deploying, build and push your custom image:

```bash
# Build the image with baked-in config
./build-image.sh

# Push to your internal registry
podman push registry.internal.local/homepage-redbull:latest
```

See [../BAKED-IMAGE.md](../BAKED-IMAGE.md) for detailed build instructions.

## Quick Start

### 1. Create API Token Secrets

```bash
# Create secret with ArgoCD and GitLab API tokens
oc create secret generic homepage-secrets \
  --from-literal=argocd-token="YOUR_ARGOCD_TOKEN" \
  --from-literal=gitlab-token="YOUR_GITLAB_TOKEN"
```

See [SECRETS.md](SECRETS.md) for token generation instructions.

### 2. Deploy with Helm

```bash
# Deploy with default values
helm install homepage ./homepage-openshift

# Or specify custom image details
helm install homepage ./homepage-openshift \
  --set image.registry=registry.internal.local \
  --set image.repository=homepage-redbull \
  --set image.tag=v1.0.0
```

### 3. Access the Dashboard

```bash
# Get the Route URL
oc get route homepage -o jsonpath='{.spec.host}'

# Example output: homepage-default.apps.cluster.internal.local
# Access at: https://homepage-default.apps.cluster.internal.local
```

## Configuration

### Image Settings

```yaml
image:
  registry: registry.internal.local
  repository: homepage-redbull
  pullPolicy: IfNotPresent
  tag: "latest"
```

### Resource Limits

```yaml
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

### Route Configuration

```yaml
route:
  enabled: true
  host: ""  # Auto-generated if empty
  tls:
    enabled: true
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
```

### Environment Variables

API tokens are injected from Kubernetes secrets:

```yaml
env:
  - name: HOMEPAGE_VAR_ARGOCD_TOKEN
    valueFrom:
      secretKeyRef:
        name: homepage-secrets
        key: argocd-token
  - name: HOMEPAGE_VAR_GITLAB_TOKEN
    valueFrom:
      secretKeyRef:
        name: homepage-secrets
        key: gitlab-token
```

## Updating Configuration

Since configuration is baked into the image:

1. **Edit config files** (config/services.yaml, etc.)
2. **Rebuild image** with new version tag:
   ```bash
   IMAGE_TAG=v1.0.1 ./build-image.sh
   podman push registry.internal.local/homepage-redbull:v1.0.1
   ```
3. **Upgrade Helm release**:
   ```bash
   helm upgrade homepage ./homepage-openshift --set image.tag=v1.0.1
   ```

## Upgrading

```bash
# Upgrade to new image version
helm upgrade homepage ./homepage-openshift \
  --set image.tag=v1.0.1

# Or upgrade Helm chart itself
helm upgrade homepage ./homepage-openshift
```

## Uninstalling

```bash
# Remove the Helm release
helm uninstall homepage

# Optionally remove secrets
oc delete secret homepage-secrets
```

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
oc get pods -l app.kubernetes.io/name=homepage

# View events
oc get events --sort-by='.lastTimestamp'

# Check logs
oc logs -l app.kubernetes.io/name=homepage
```

### Image Pull Errors

```bash
# Verify image exists in registry
podman search registry.internal.local/homepage-redbull

# Check imagePullSecrets if using private registry
oc get secrets

# Update values.yaml with pull secret
imagePullSecrets:
  - name: internal-registry-secret
```

### Widgets Not Working

```bash
# Verify secrets exist
oc get secret homepage-secrets -o yaml

# Check environment variables in pod
oc exec -it $(oc get pod -l app.kubernetes.io/name=homepage -o name) -- env | grep HOMEPAGE_VAR
```

### Route Not Accessible

```bash
# Check route status
oc get route homepage

# Verify TLS termination
oc describe route homepage
```

## Values Reference

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.registry` | Container registry URL | `registry.internal.local` |
| `image.repository` | Image repository name | `homepage-redbull` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `imagePullSecrets` | Registry pull secrets | `[]` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `3000` |
| `route.enabled` | Enable OpenShift Route | `true` |
| `route.host` | Custom hostname | `""` (auto-generated) |
| `route.tls.enabled` | Enable TLS | `true` |
| `resources.limits.cpu` | CPU limit | `500m` |
| `resources.limits.memory` | Memory limit | `512Mi` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `128Mi` |

## Related Documentation

- [Main README](../README.md) - Project overview
- [Baked Image Guide](../BAKED-IMAGE.md) - Building custom images
- [Secrets Management](SECRETS.md) - API token configuration
- [Icons Guide](../ICONS-OFFLINE.md) - Custom icons setup

## Support

For issues or questions:
- GitHub Issues: https://github.com/roiblum1/homeage-redbull/issues
- Documentation: See links above
