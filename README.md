# Homepage Red Bull Hub

A customized Homepage dashboard deployment for Red Bull team services, optimized for both Docker and OpenShift environments.

## 🎯 Features

- **Dark Theme** with custom background and blur effects
- **Multi-Section Layout**: Services, Developer Tools, ArgoCD Instances
- **Enhanced Widgets**: Resources, Search, DateTime, Bookmarks
- **OpenShift Native**: Custom Helm chart with Route support
- **Local Development**: Docker Compose setup

## 🚀 Quick Start

### Local Development (Docker)
```bash
podman-compose up -d
# or
docker-compose up -d

# Access at http://localhost:3000
```

### OpenShift Deployment
```bash
helm install homepage ./homepage-openshift -f homepage-openshift/values-openshift.yaml
```

## 📋 Service Sections

### 🛠️ Services
- **VLAN Manager** - Network VLAN management
- **Cluster Navigator** - OpenShift cluster navigation  
- **GitLab Project** - Specific repository
- **ArgoCD Main** - Primary deployment instance

### 👨‍💻 Developer Tools
- **Confluence** - Team documentation
- **GitLab Team** - Team group repositories

### 🚢 ArgoCD Instances
- **Dev Environment** - Development deployments
- **Staging Environment** - Staging deployments  
- **Production Environment** - Production deployments

## 🎨 Visual Features

- **Background**: Custom image with blur/saturation effects
- **Layout**: 4-column equal-height cards
- **Headers**: Underlined style
- **Cards**: Glass-morphism blur effects
- **Bookmarks**: Icon-only bottom section

## 📁 Project Structure

```
.
├── assets/                          # Static assets
│   ├── backgrounds/                # Background images  
│   ├── icons/                      # Custom icons
│   └── README.md                   # Assets documentation
├── config/                          # Local config files
│   ├── services.yaml               # Service definitions
│   ├── settings.yaml               # Theme and layout
│   ├── widgets.yaml                # Header widgets
│   └── bookmarks.yaml              # Bottom bookmarks
├── homepage-openshift/             # OpenShift Helm chart
│   ├── templates/                  # Kubernetes templates
│   ├── values-openshift.yaml       # Connected deployment values
│   ├── values-airgap.yaml          # Air-gapped deployment values
│   ├── AIRGAP-DEPLOYMENT.md        # Air-gapped deployment guide
│   └── README-OpenShift.md         # OpenShift documentation
├── docker-compose.yml             # Local development
└── README.md                       # This file
```

## 🔧 Customization

### Update Service URLs
Edit `config/services.yaml` or `homepage-openshift/values-openshift.yaml`:

```yaml
- Services:
    - VLAN Manager:
        href: http://your-vlan-manager:8000
        description: Network VLAN management tool
        icon: mdi-network
```

### Change Background Image
1. Add image to `/backgrounds/` directory
2. Update settings:
```yaml
background:
  image: /backgrounds/your-image.jpg
  blur: sx
  saturate: 50
  brightness: 50
  opacity: 20
```

### OpenShift Background Images
```bash
# Create ConfigMap with your background
oc create configmap homepage-backgrounds --from-file=your-background.jpg

# Update values.yaml to mount the ConfigMap
# See homepage-openshift/README-OpenShift.md for details
```

## 🌐 Environment Support

- ✅ **Connected**: Full internet access with external resources
- ✅ **Disconnected/Air-gapped**: Complete offline deployment support
- ✅ **OpenShift**: Native Routes, security contexts, RBAC
- ✅ **Kubernetes**: Standard ingress and security policies

### 🔒 Air-Gapped Deployment

For completely disconnected environments:
```bash
# Use air-gapped configuration
helm install homepage ./homepage-openshift -f homepage-openshift/values-airgap.yaml

# See detailed guide
# homepage-openshift/AIRGAP-DEPLOYMENT.md
```

**Air-gapped features:**
- ✅ No external image dependencies
- ✅ Local background images included (`assets/backgrounds/`)
- ✅ Internal service references only
- ✅ No external API requirements

## 📖 Documentation

- [OpenShift Deployment Guide](homepage-openshift/README-OpenShift.md)
- [Configuration Examples](config/)

## 🏗️ Built With

- [Homepage](https://gethomepage.dev/) - The dashboard application
- [Helm](https://helm.sh/) - Kubernetes package manager
- [OpenShift](https://www.redhat.com/en/technologies/cloud-computing/openshift) - Container platform
- [Docker/Podman](https://podman.io/) - Container runtime

## 📝 License

This project customizes the open-source Homepage project for Red Bull team use.

---

**🚀 Ready to deploy your team dashboard!**