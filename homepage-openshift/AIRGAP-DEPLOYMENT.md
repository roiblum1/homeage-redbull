# Air-Gapped / Disconnected Environment Deployment

This guide provides step-by-step instructions for deploying Homepage in completely disconnected/air-gapped environments.

## 🔒 Prerequisites for Air-Gapped Deployment

### Required Components
- **OpenShift/Kubernetes cluster** (air-gapped)
- **Internal container registry** (Harbor, Nexus, etc.)
- **Helm 3.x** installed on bastion/management host
- **Image mirroring tools** (skopeo, podman, docker)

### Network Requirements
- ❌ **No internet access** from cluster nodes
- ✅ **Internal DNS** for service resolution
- ✅ **Internal container registry** accessible from cluster

## 🚢 Image Preparation

### 1. Mirror Homepage Image

On a **connected machine** with access to both internet and internal registry:

```bash
# Pull the Homepage image
podman pull ghcr.io/gethomepage/homepage:latest

# Tag for your internal registry
podman tag ghcr.io/gethomepage/homepage:latest registry.internal.local/homepage:latest

# Push to internal registry
podman push registry.internal.local/homepage:latest
```

### 2. Alternative: Save and Load Image

If direct registry push is not possible:

```bash
# Save image to tar file
podman save ghcr.io/gethomepage/homepage:latest -o homepage.tar

# Transfer to air-gapped environment
# scp homepage.tar user@airgapped-host:/tmp/

# On air-gapped environment
podman load -i /tmp/homepage.tar
podman tag ghcr.io/gethomepage/homepage:latest registry.internal.local/homepage:latest
podman push registry.internal.local/homepage:latest
```

## 📁 Background Image Setup

### Method 1: ConfigMap (Recommended)

```bash
# Create ConfigMap with your background images
oc create configmap homepage-backgrounds \
  --from-file=v4-background-dark.jpg=/path/to/your/image.jpg \
  --from-file=other-background.jpg=/path/to/other/image.jpg
```

### Method 2: Persistent Volume

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: homepage-backgrounds-pvc
spec:
  accessModes:
    - ReadOnlyMany
  resources:
    requests:
      storage: 1Gi
  storageClassName: your-storage-class
```

## ⚙️ Air-Gapped Values Configuration

Create `values-airgap.yaml`:

```yaml
replicaCount: 1

image:
  registry: registry.internal.local  # Your internal registry
  repository: homepage
  pullPolicy: IfNotPresent
  tag: "latest"

# Image pull secret for internal registry (if required)
imagePullSecrets:
  - name: internal-registry-secret

extraEnv:
  - name: HOMEPAGE_ALLOWED_HOSTS
    value: "*"

config:
  allowedHosts: []
  
  services: |
    ---
    - Services:
        - VLAN Manager:
            href: http://vlan-manager.internal.local:8000
            description: Network VLAN management tool
            icon: mdi-network
        
        - Cluster Navigator:
            href: http://navigator.internal.local:8001
            description: OpenShift cluster navigation tool
            icon: mdi-compass-outline
        
        - GitLab Project:
            href: https://gitlab.internal.local/your-team/project
            description: Specific project repository
            icon: mdi-git
        
        - ArgoCD Main:
            href: https://argocd.internal.local
            description: Primary GitOps deployment instance
            icon: mdi-ship-wheel

    - Developer Tools:
        - Confluence:
            href: https://confluence.internal.local
            description: Team documentation and knowledge base
            icon: mdi-book-open-page-variant
        
        - GitLab Team:
            href: https://gitlab.internal.local/groups/your-team
            description: Team group repositories
            icon: mdi-gitlab

    - ArgoCD Instances:
        - ArgoCD Dev:
            href: https://argocd-dev.internal.local
            description: Development environment deployments
            icon: mdi-ship-wheel
        
        - ArgoCD Staging:
            href: https://argocd-staging.internal.local
            description: Staging environment deployments
            icon: mdi-ship-wheel
        
        - ArgoCD Production:
            href: https://argocd-prod.internal.local
            description: Production environment deployments
            icon: mdi-ship-wheel

  settings: |
    ---
    title: Team Services Dashboard
    # No external favicon for air-gapped
    theme: dark
    color: slate
    background: 
      image: /backgrounds/v4-background-dark.jpg
      blur: sx
      saturate: 50
      brightness: 50
      opacity: 20
    layout:
      Services:
        style: row
        columns: 4
        equalHeight: true
      Developer Tools:
        style: row
        columns: 4
        equalHeight: true
      ArgoCD Instances:
        style: row
        columns: 4
        equalHeight: true
    headerStyle: underlined
    cardBlur: md
    hideVersion: true

  widgets: |
    ---
    - resources:
        backend: resources
        expanded: true
        cpu: true
        memory: true
    
    - search:
        provider: google
        target: _blank
        
    - datetime:
        text_size: xl
        format:
          timeStyle: short
          dateStyle: short

  bookmarks: |
    ---
    - Internal Tools:
        - Internal GitLab:
            - icon: mdi-gitlab
              href: https://gitlab.internal.local
        - Internal Registry:
            - icon: mdi-docker
              href: https://registry.internal.local
        - Documentation:
            - icon: mdi-book-open-page-variant
              href: https://docs.internal.local
              
    - DevOps:
        - OpenShift Console:
            - icon: mdi-kubernetes
              href: https://console.openshift.local
        - ArgoCD:
            - icon: mdi-ship-wheel
              href: https://argocd.internal.local
        - Nexus:
            - icon: mdi-package-variant
              href: https://nexus.internal.local
              
    - Monitoring:
        - Grafana:
            - icon: mdi-chart-line
              href: https://grafana.internal.local
        - Prometheus:
            - icon: mdi-fire
              href: https://prometheus.internal.local

# OpenShift compatible security contexts
podSecurityContext: {}

securityContext:
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
  readOnlyRootFilesystem: false
  runAsNonRoot: true
  privileged: false
  seccompProfile:
    type: RuntimeDefault

service:
  type: ClusterIP
  port: 80

# Disable ingress, use OpenShift Routes
ingress:
  enabled: false

# OpenShift Route configuration
route:
  enabled: true
  host: "homepage.apps.internal.local"  # Your internal domain
  annotations: {}
  tls:
    enabled: true
    termination: edge
    insecureEdgeTerminationPolicy: Redirect

rbac:
  enabled: true

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi

# Volume configuration for air-gapped
volumes:
  - name: config
    configMap:
      name: "{{ include \"homepage.fullname\" . }}-config"
  # Background images via ConfigMap
  - name: backgrounds
    configMap:
      name: homepage-backgrounds

volumeMounts:
  - name: config
    mountPath: "/app/config"
    readOnly: true
  - name: backgrounds
    mountPath: "/app/public/backgrounds"
    readOnly: true

nodeSelector: {}
tolerations: []
affinity: {}
```

## 🚀 Deployment Steps

### 1. Create Image Pull Secret (if needed)

```bash
oc create secret docker-registry internal-registry-secret \
  --docker-server=registry.internal.local \
  --docker-username=your-username \
  --docker-password=your-password \
  --docker-email=your-email@company.com
```

### 2. Create Background Images ConfigMap

```bash
oc create configmap homepage-backgrounds \
  --from-file=v4-background-dark.jpg=/path/to/your/background.jpg
```

### 3. Deploy Homepage

```bash
# Deploy with air-gapped values
helm install homepage ./homepage-openshift -f values-airgap.yaml

# Or with namespace
helm install homepage ./homepage-openshift \
  -f values-airgap.yaml \
  -n homepage-system \
  --create-namespace
```

### 4. Verify Deployment

```bash
# Check pods
oc get pods -l app.kubernetes.io/name=homepage

# Check route
oc get route homepage

# Check logs
oc logs -l app.kubernetes.io/name=homepage
```

## 🔧 Troubleshooting Air-Gapped Issues

### Image Pull Errors
```bash
# Check image pull secret
oc describe secret internal-registry-secret

# Verify registry access
podman login registry.internal.local

# Check pod events
oc describe pod <homepage-pod-name>
```

### Missing Background Images
```bash
# Check ConfigMap
oc describe configmap homepage-backgrounds

# Verify mount
oc exec <homepage-pod> -- ls /app/public/backgrounds
```

### DNS Resolution Issues
```bash
# Test internal DNS
oc exec <homepage-pod> -- nslookup gitlab.internal.local

# Check service endpoints
oc get endpoints
```

## ✅ Air-Gapped Deployment Checklist

- [ ] Homepage image mirrored to internal registry
- [ ] Background images uploaded to ConfigMap or PVC
- [ ] All service URLs point to internal services
- [ ] No external favicon or resource URLs
- [ ] Image pull secrets configured (if required)
- [ ] Internal DNS resolution working
- [ ] OpenShift Route configured with internal domain
- [ ] All bookmarks point to internal services

## 🔒 Security Considerations

1. **Registry Security**: Use TLS and authentication for internal registry
2. **Image Scanning**: Scan mirrored images for vulnerabilities  
3. **RBAC**: Apply least-privilege access controls
4. **Network Policies**: Restrict pod-to-pod communication
5. **Secret Management**: Secure image pull secrets and credentials

---

Your Homepage dashboard is now ready for air-gapped deployment! 🚀