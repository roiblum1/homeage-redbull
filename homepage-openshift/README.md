# Homepage Helm Chart for OpenShift

Air-gapped ready Homepage dashboard with ArgoCD and GitLab integrations.

## 🚀 Quick Start

```bash
# Deploy Homepage
helm install homepage . -n homepage --create-namespace

# With custom values
helm install homepage . -f custom-values.yaml
```

## 📋 Prerequisites

1. **OpenShift/Kubernetes cluster** (v1.23+)
2. **Internal container registry** (for air-gapped)
3. **Helm 3.x**
4. **Background images ConfigMap** (optional)
5. **API tokens Secret** (for widgets)

## 🔐 Secrets Setup

Create secrets for ArgoCD and GitLab integrations:

```bash
oc create secret generic homepage-secrets \
  --from-literal=argocd-token='YOUR_ARGOCD_TOKEN' \
  --from-literal=gitlab-token='YOUR_GITLAB_TOKEN' \
  -n homepage
```

**See [SECRETS.md](SECRETS.md) for detailed token setup.**

## 🖼️ Background Images

Create ConfigMap with your background images:

```bash
oc create configmap homepage-backgrounds \
  --from-file=v4-background-dark.jpg=../assets/backgrounds/v4-background-dark.jpg \
  -n homepage
```

## ⚙️ Configuration

### Key Values to Customize

```yaml
# Internal Registry (for air-gapped)
image:
  registry: registry.internal.local  # Change this
  repository: homepage
  tag: latest

# OpenShift Route
route:
  host: "homepage.apps.internal.local"  # Change this

# Service URLs (in config.services)
- Core GitOps:
    - GitLab GitOps Project:
        href: https://gitlab.internal.local/your-team/gitops  # Change this
    - ArgoCD Main:
        href: https://argocd.internal.local  # Change this
```

## 📦 What's Included

- **6 Service Sections**:
  - Core GitOps (GitLab, ArgoCD, repo count)
  - Documentation (Confluence)
  - Monitoring (Grafana)
  - Internal Tools (VLAN Manager, Cluster Navigator)
  - Management Clusters (6x OpenShift consoles + ArgoCD)
  - DC Systems (UCS, NetBox, OpenManage, OneView)

- **Widgets**:
  - ArgoCD application stats
  - GitLab group repository count
  - Resources (CPU/Memory)
  - Date/Time

- **Features**:
  - Air-gapped compatible
  - OpenShift Routes
  - Dark theme with blur effects
  - Equal height cards
  - Quick Links bookmarks

## 🌐 Air-Gapped Deployment

**See [AIRGAP-DEPLOYMENT.md](AIRGAP-DEPLOYMENT.md) for complete guide.**

### Quick Steps

1. **Mirror image to internal registry**:
   ```bash
   podman pull ghcr.io/gethomepage/homepage:latest
   podman tag ghcr.io/gethomepage/homepage:latest registry.internal.local/homepage:latest
   podman push registry.internal.local/homepage:latest
   ```

2. **Create secrets and ConfigMaps**
3. **Deploy with Helm**:
   ```bash
   helm install homepage . \
     --set image.registry=registry.internal.local \
     --set route.host=homepage.apps.internal.local
   ```

## 📖 Documentation

- **[AIRGAP-DEPLOYMENT.md](AIRGAP-DEPLOYMENT.md)** - Air-gapped deployment guide
- **[SECRETS.md](SECRETS.md)** - API token configuration
- **[README-OpenShift.md](README-OpenShift.md)** - OpenShift-specific features

## 🔧 Customization Examples

### Change Background
```yaml
config:
  settings: |
    background:
      image: /backgrounds/your-image.jpg
      blur: md
      opacity: 40
```

### Add More Services
```yaml
config:
  services: |
    - Your Section:
        - Your Service:
            href: https://service.internal.local
            description: Your description
            icon: mdi-icon-name
```

### Adjust Resources
```yaml
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 200m
    memory: 256Mi
```

## ✅ Verification

```bash
# Check deployment
oc get pods -l app.kubernetes.io/name=homepage

# Get Route URL
oc get route homepage -o jsonpath='{.spec.host}'

# Check logs
oc logs -l app.kubernetes.io/name=homepage
```

## 🚨 Troubleshooting

### Widgets not showing
- Check secrets are created: `oc get secret homepage-secrets`
- Verify tokens are valid
- Check logs for API errors

### Background image not loading
- Verify ConfigMap: `oc get configmap homepage-backgrounds`
- Check image is mounted: `oc exec <pod> -- ls /app/public/backgrounds`

### Route not working
- Check host validation in environment variables
- Verify TLS configuration

## 📝 License

Based on the open-source [Homepage](https://github.com/gethomepage/homepage) project.

---

**Ready for air-gapped OpenShift deployment!** 🚀