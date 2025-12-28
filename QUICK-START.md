# Homepage Red Bull Hub - Quick Start Guide

Choose your deployment method based on your needs:

## 🚀 Method 1: Baked-In Image (Recommended for Air-Gapped)

**Best for:** Immutable deployments, version control, simplicity

```bash
# 1. Build custom image with config included
./build-image.sh

# 2. Push to your internal registry
podman push registry.internal.local/homepage-redbull:latest

# 3. Create API token secrets
oc create secret generic homepage-secrets \
  --from-literal=argocd-token="YOUR_ARGOCD_TOKEN" \
  --from-literal=gitlab-token="YOUR_GITLAB_TOKEN"

# 4. Deploy to OpenShift
helm install homepage ./homepage-openshift \
  -f homepage-openshift/values-baked-image.yaml
```

**Pros:**
- ✅ Single artifact (image contains everything)
- ✅ Faster pod startup (no initContainer)
- ✅ Immutable and versioned
- ✅ Simpler troubleshooting

**Cons:**
- ❌ Config changes require image rebuild
- ❌ Larger image size

See [BAKED-IMAGE.md](BAKED-IMAGE.md) for details.

---

## 🔧 Method 2: ConfigMap-Based (Default)

**Best for:** Frequent config changes, dynamic environments

```bash
# 1. Create API token secrets
oc create secret generic homepage-secrets \
  --from-literal=argocd-token="YOUR_ARGOCD_TOKEN" \
  --from-literal=gitlab-token="YOUR_GITLAB_TOKEN"

# 2. Deploy with default values (includes ConfigMap)
helm install homepage ./homepage-openshift
```

**Pros:**
- ✅ Update config without rebuilding image
- ✅ Smaller base image
- ✅ Easy config changes via `helm upgrade`

**Cons:**
- ❌ Requires ConfigMap management
- ❌ Slower startup (initContainer copies files)

See [homepage-openshift/README.md](homepage-openshift/README.md) for details.

---

## 🧪 Local Testing

Test with Docker/Podman before deploying:

```bash
# Start locally
podman-compose up -d

# Access at http://localhost:3000

# View logs
podman-compose logs -f

# Stop
podman-compose down
```

---

## 📊 Comparison Table

| Feature | Baked Image | ConfigMap |
|---------|-------------|-----------|
| Deployment complexity | Low | Medium |
| Pod startup time | Fast | Slower (initContainer) |
| Config updates | Rebuild image | Update ConfigMap |
| Air-gapped friendly | Excellent | Good |
| Version control | Image tag | Helm values |
| Rollback | Image rollback | Helm rollback |
| Storage | Image registry | etcd (ConfigMap) |

---

## 🔐 Required Secrets

Both methods require API tokens for widgets:

```bash
# ArgoCD Token
# Generate at: ArgoCD UI → User Info → Tokens

# GitLab Token
# Generate at: GitLab → User Settings → Access Tokens
# Scopes: read_api, read_repository

# Create secret
oc create secret generic homepage-secrets \
  --from-literal=argocd-token="YOUR_ARGOCD_TOKEN" \
  --from-literal=gitlab-token="YOUR_GITLAB_TOKEN"
```

See [homepage-openshift/SECRETS.md](homepage-openshift/SECRETS.md) for detailed instructions.

---

## 🌐 Accessing the Dashboard

After deployment:

```bash
# Get the Route URL
oc get route homepage -o jsonpath='{.spec.host}'

# Example: https://homepage-default.apps.cluster.internal.local
```

---

## 🐛 Troubleshooting

### Pods Not Starting

```bash
# Check pod status
oc get pods -l app.kubernetes.io/name=homepage

# Check events
oc get events --sort-by='.lastTimestamp'

# View logs
oc logs -l app.kubernetes.io/name=homepage
```

### Widgets Not Loading

```bash
# Verify secrets exist
oc get secret homepage-secrets

# Check environment variables
oc exec -it $(oc get pod -l app.kubernetes.io/name=homepage -o name) -- env | grep HOMEPAGE_VAR

# Check network connectivity from pod
oc exec -it $(oc get pod -l app.kubernetes.io/name=homepage -o name) -- curl -I http://gitlab.internal.local
```

### ConfigMap Issues (Method 2 only)

```bash
# Verify ConfigMap exists
oc get configmap -l app.kubernetes.io/name=homepage

# Check ConfigMap content
oc get configmap <configmap-name> -o yaml
```

---

## 📚 Full Documentation

- [Main README](README.md) - Overview and features
- [Baked Image Guide](BAKED-IMAGE.md) - Custom image building
- [Air-Gapped Deployment](homepage-openshift/AIRGAP-DEPLOYMENT.md) - Offline setup
- [Secrets Management](homepage-openshift/SECRETS.md) - Token configuration
- [Helm Chart README](homepage-openshift/README.md) - Detailed Helm docs
