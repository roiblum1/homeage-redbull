# Building and Deploying Homepage with Baked-In Configuration

This guide explains how to build a custom Homepage container image with your configuration files already included, eliminating the need for ConfigMaps during deployment.

## 🎯 Benefits of Baked-In Configuration

- **Simpler Deployment**: No ConfigMaps to manage
- **Faster Startup**: No initContainer copying files
- **Immutable Configuration**: Config is versioned with the image
- **Easier Rollback**: Redeploy previous image version to restore old config
- **Air-Gapped Ready**: Everything bundled in one artifact

## 📦 What Gets Baked Into the Image

The custom image includes:

- ✅ All service definitions (`config/services.yaml`)
- ✅ Dashboard settings and theme (`config/settings.yaml`)
- ✅ Header widgets configuration (`config/widgets.yaml`)
- ✅ Bookmarks configuration (`config/bookmarks.yaml`)
- ✅ Background images (`assets/backgrounds/`)
- ✅ Environment variables for TLS skip and allowed hosts

## 🔨 Building the Image

### Prerequisites

- Podman or Docker installed
- Access to base image: `ghcr.io/gethomepage/homepage:latest`
- (For air-gapped) Base image already mirrored to internal registry

### Build Command

```bash
# Simple build with defaults
./build-image.sh

# Custom configuration
IMAGE_NAME=homepage-redbull \
IMAGE_TAG=v1.0.0 \
REGISTRY=registry.internal.local \
./build-image.sh
```

### Build Script Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `IMAGE_NAME` | `homepage-redbull` | Name of the image |
| `IMAGE_TAG` | `latest` | Image tag/version |
| `REGISTRY` | `registry.internal.local` | Target registry URL |

### Manual Build

If you prefer to build manually:

```bash
# Build the image
podman build -t homepage-redbull:latest -f Containerfile .

# Tag for your registry
podman tag homepage-redbull:latest registry.internal.local/homepage-redbull:latest

# Push to registry
podman push registry.internal.local/homepage-redbull:latest
```

## 🧪 Testing Locally

Test the baked image before deploying:

```bash
# Run the container
podman run -d \
  --name homepage-test \
  -p 3000:3000 \
  -e HOMEPAGE_VAR_ARGOCD_TOKEN="your-token" \
  -e HOMEPAGE_VAR_GITLAB_TOKEN="your-token" \
  homepage-redbull:latest

# Access at http://localhost:3000
# Check logs
podman logs homepage-test

# Clean up
podman stop homepage-test && podman rm homepage-test
```

## 🚀 Deploying to OpenShift/Kubernetes

### Step 1: Push Image to Registry

```bash
# Login to your internal registry
podman login registry.internal.local

# Push the image
podman push registry.internal.local/homepage-redbull:latest
```

### Step 2: Create Secrets (API Tokens)

```bash
# Create secret with ArgoCD and GitLab tokens
oc create secret generic homepage-secrets \
  --from-literal=argocd-token="YOUR_ARGOCD_TOKEN" \
  --from-literal=gitlab-token="YOUR_GITLAB_TOKEN"
```

### Step 3: Deploy with Helm

```bash
# Deploy using baked-image values
helm install homepage ./homepage-openshift \
  -f homepage-openshift/values-baked-image.yaml

# Or specify image details directly
helm install homepage ./homepage-openshift \
  -f homepage-openshift/values-baked-image.yaml \
  --set image.registry=registry.internal.local \
  --set image.repository=homepage-redbull \
  --set image.tag=v1.0.0
```

### Step 4: Verify Deployment

```bash
# Check pod status
oc get pods -l app.kubernetes.io/name=homepage

# Check logs
oc logs -l app.kubernetes.io/name=homepage

# Get route URL
oc get route homepage -o jsonpath='{.spec.host}'
```

## 🔄 Updating Configuration

When you need to update the configuration:

1. **Edit configuration files** in `config/` directory
2. **Rebuild the image** with a new tag:
   ```bash
   IMAGE_TAG=v1.0.1 ./build-image.sh
   ```
3. **Push to registry**:
   ```bash
   podman push registry.internal.local/homepage-redbull:v1.0.1
   ```
4. **Upgrade Helm deployment**:
   ```bash
   helm upgrade homepage ./homepage-openshift \
     -f homepage-openshift/values-baked-image.yaml \
     --set image.tag=v1.0.1
   ```

## 🔀 ConfigMap vs Baked Image Comparison

| Feature | ConfigMap Approach | Baked Image Approach |
|---------|-------------------|---------------------|
| Configuration updates | Update ConfigMap, restart pod | Rebuild image, redeploy |
| Deployment complexity | Higher (ConfigMap + initContainer) | Lower (just image) |
| Startup time | Slower (copy from ConfigMap) | Faster (already in image) |
| Version control | Separate (Helm values) | Unified (image tag) |
| Rollback | Helm rollback | Image rollback |
| Air-gapped | Requires ConfigMap YAML | Single image artifact |
| Best for | Frequent config changes | Stable, versioned releases |

## 📋 Containerfile Explained

The `Containerfile` builds upon the official Homepage image:

```dockerfile
FROM ghcr.io/gethomepage/homepage:latest

# Copy your config files
COPY config/*.yaml /app/config/

# Copy background images
COPY assets/backgrounds/ /app/public/backgrounds/

# Fix permissions (Homepage runs as UID 1000)
RUN chown -R 1000:1000 /app/config /app/public/backgrounds

# Set default environment variables
ENV NODE_TLS_REJECT_UNAUTHORIZED="0"
```

## 🐛 Troubleshooting

### Image Build Fails

```bash
# Check if base image is accessible
podman pull ghcr.io/gethomepage/homepage:latest

# Verify Containerfile syntax
podman build --no-cache -t test -f Containerfile .
```

### Permission Errors in Pod

The image runs as UID 1000 (non-root). Ensure:
- Config files are owned by UID 1000
- OpenShift SCC allows `runAsUser: 1000`

### Configuration Not Applied

```bash
# Check if files are in the image
podman run --rm homepage-redbull:latest ls -la /app/config/

# Expected output:
# services.yaml
# settings.yaml
# widgets.yaml
# bookmarks.yaml
```

### Widgets Not Working

API tokens still need to be provided via secrets:

```bash
# Verify secret exists
oc get secret homepage-secrets -o yaml

# Check environment variables in pod
oc exec -it <pod-name> -- env | grep HOMEPAGE_VAR
```

## 🔐 Security Considerations

- **Image Scanning**: Scan images for vulnerabilities before deployment
- **Tag Immutability**: Use specific version tags (not `latest`) in production
- **Registry Access**: Restrict who can push images to your registry
- **Secrets Management**: Never bake API tokens into the image - always use Kubernetes secrets

## 📚 Related Documentation

- [Air-Gapped Deployment Guide](homepage-openshift/AIRGAP-DEPLOYMENT.md)
- [Secrets Management](homepage-openshift/SECRETS.md)
- [Helm Chart README](homepage-openshift/README.md)
- [Main README](README.md)
