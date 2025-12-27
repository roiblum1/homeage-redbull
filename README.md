# Homepage Red Bull Hub

A customized Homepage dashboard deployment for Red Bull team services, optimized for both Docker and OpenShift environments with air-gapped support.

## 🎯 Features

- **Dark Theme** with custom background and blur effects
- **Multi-Section Layout**: Core GitOps, DevOps, Internal Tools, Management Clusters, DC Systems
- **Performance Optimized**: Lazy loading, reduced widget polling, status indicators
- **Enhanced Widgets**: ArgoCD integration, GitLab API, Resources, DateTime
- **OpenShift Native**: Custom Helm chart with Route support
- **Air-Gapped Ready**: Complete offline deployment capability
- **Local Development**: Podman/Docker Compose setup

## 🚀 Quick Start

### Local Development (Docker)
```bash
podman-compose up -d
# or
docker-compose up -d

# Access at http://localhost:3000
```

### OpenShift Deployment (Air-Gapped)
```bash
# Install with air-gapped configuration
helm install homepage ./homepage-openshift

# Access via OpenShift Route
# Default: https://homepage.apps.internal.local
```

## 📋 Service Sections

### ⚙️ Core GitOps

- **GitLab GitOps Project** - Main GitOps repository
- **ArgoCD Main** - Main Argo CD instance with app stats widget

### 👨‍💻 DevOps

- **GitLab Team Group** - Team group with repo count widget
- **Confluence** - Team documentation
- **Grafana Dashboard** - Main operational dashboard

### 🛠️ Internal Tools

- **VLAN Manager** - Network VLAN management tool
- **Cluster Navigator** - OpenShift cluster navigation tool

### 🚢 Management Clusters

- **mgmt-01 through mgmt-06** - OpenShift consoles and ArgoCD instances (12 services)

### 🖥️ DC Systems

- **Cisco UCS** - UCS Manager
- **NetBox** - IPAM / DCIM
- **OpenManage** - Dell OpenManage
- **OneView** - HPE OneView

## 🎨 Visual Features

- **Background**: Custom image with blur/saturation effects
- **Layout**: Multi-column equal-height cards (2-4 columns per section)
- **Headers**: Underlined style
- **Theme**: Dark theme with zinc color palette
- **Status Indicators**: Colored dots showing service health
- **Bookmarks**: Icon-only quick links

## ⚡ Performance Optimizations

- **Lazy Loading**: Widgets load only when visible (`lazyLoad: true`)
- **Reduced Widget Polling**:
  - ArgoCD widget: 30 seconds (vs. default 10s)
  - GitLab API: 60 seconds (vs. default 10s)
- **Status Indicators**: Lightweight ping checks with dot styling
- **Optimized Resources**: CPU/memory limits configured

## 📁 Project Structure

```
.
├── assets/                          # Static assets
│   └── backgrounds/                # Background images (v1-v4)
├── config/                          # Local config files
│   ├── services.yaml               # Service definitions
│   ├── settings.yaml               # Theme and layout
│   ├── widgets.yaml                # Header widgets
│   └── bookmarks.yaml              # Bottom bookmarks
├── homepage-openshift/             # OpenShift Helm chart
│   ├── templates/                  # Kubernetes templates
│   ├── values.yaml                 # Air-gapped deployment values
│   ├── Chart.yaml                  # Helm chart metadata
│   ├── AIRGAP-DEPLOYMENT.md        # Air-gapped deployment guide
│   ├── SECRETS.md                  # Token management guide
│   └── README.md                   # Helm chart documentation
├── docker-compose.yml              # Local development
├── RECOMMENDATIONS.md              # Best practices and suggestions
└── README.md                        # This file
```

## 🔧 Customization

### Update Service URLs

Edit `config/services.yaml` or `homepage-openshift/values.yaml`:

```yaml
- Internal Tools:
    - VLAN Manager:
        href: http://your-vlan-manager:8000
        description: Network VLAN management tool
        icon: mdi-network
        ping: http://your-vlan-manager:8000
        statusStyle: dot
```

### Change Background Image

1. Add image to `assets/backgrounds/` directory
2. Update `config/settings.yaml`:

```yaml
background:
  image: /backgrounds/your-image.jpg
  blur: sm
  saturate: 60
  brightness: 70
  opacity: 35
```

### Configure API Tokens

For ArgoCD and GitLab widgets:

```bash
# Local development - set environment variables in docker-compose.yml
HOMEPAGE_VAR_ARGOCD_TOKEN: "your-argocd-token"
HOMEPAGE_VAR_GITLAB_TOKEN: "your-gitlab-token"

# OpenShift - create secret
oc create secret generic homepage-secrets \
  --from-literal=argocd-token="your-argocd-token" \
  --from-literal=gitlab-token="your-gitlab-token"
```

See [SECRETS.md](homepage-openshift/SECRETS.md) for detailed token setup.

### Handle Self-Signed Certificates

For services with self-signed or invalid TLS certificates (common in air-gapped environments):

**Already configured** - Both docker-compose.yml and Helm chart include:

```yaml
NODE_TLS_REJECT_UNAUTHORIZED: "0"
```

This allows Homepage to connect to services with:
- Self-signed certificates
- Expired certificates
- Certificate hostname mismatches

**Security Note**: Only use this in trusted internal networks. For production with internet access, use proper CA-signed certificates.

## 🌐 Environment Support

- ✅ **Connected**: Full internet access with external resources
- ✅ **Disconnected/Air-gapped**: Complete offline deployment support
- ✅ **OpenShift**: Native Routes, security contexts, RBAC
- ✅ **Kubernetes**: Standard ingress and security policies

### 🔒 Air-Gapped Deployment

For completely disconnected environments:

```bash
# Install with default air-gapped configuration
helm install homepage ./homepage-openshift

# See detailed guide at homepage-openshift/AIRGAP-DEPLOYMENT.md
```

**Air-gapped features:**

- ✅ No external image dependencies
- ✅ Local background images included (`assets/backgrounds/`)
- ✅ Internal service references only
- ✅ No external API requirements
- ✅ All icons bundled in Homepage image (Material Design Icons)

## 📖 Documentation

- [Helm Chart README](homepage-openshift/README.md) - OpenShift deployment guide
- [Air-Gapped Deployment](homepage-openshift/AIRGAP-DEPLOYMENT.md) - Offline deployment guide
- [Secrets Management](homepage-openshift/SECRETS.md) - Token configuration
- [Recommendations](RECOMMENDATIONS.md) - Best practices and widget suggestions

## 🏗️ Built With

- [Homepage](https://gethomepage.dev/) - The dashboard application
- [Helm](https://helm.sh/) - Kubernetes package manager
- [OpenShift](https://www.redhat.com/en/technologies/cloud-computing/openshift) - Container platform
- [Docker/Podman](https://podman.io/) - Container runtime

## 📝 License

This project customizes the open-source Homepage project for Red Bull team use.

---

**🚀 Ready to deploy your team dashboard!**