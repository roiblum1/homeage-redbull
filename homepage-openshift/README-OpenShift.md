# Homepage for OpenShift

This is a customized version of the Homepage Helm chart optimized for OpenShift deployments.

## Key OpenShift Modifications

### Security Context Changes
- Removed fixed `runAsUser` and `runAsGroup` (OpenShift assigns random UIDs)
- Removed `fsGroup` from `podSecurityContext`
- Maintained non-root security requirements

### OpenShift Route Support
- Added native OpenShift Route template (`templates/route.yaml`)
- Configured with TLS edge termination by default
- Disabled standard Kubernetes Ingress

### RBAC Enhancements
- Added permissions for OpenShift Route resources
- Maintained minimal required permissions

## Installation

### Prerequisites
- OpenShift cluster (4.x+)
- Helm 3.x

### Install with Default Values
```bash
helm install homepage ./homepage-openshift
```

### Install with OpenShift-optimized Values
```bash
helm install homepage ./homepage-openshift -f values-openshift.yaml
```

### Custom Installation
```bash
helm install homepage ./homepage-openshift \
  --set route.host=homepage.apps.your-cluster.com \
  --set resources.requests.memory=256Mi \
  --set resources.limits.memory=1Gi
```

## Configuration

### Key Values for OpenShift

```yaml
# OpenShift Route (instead of Ingress)
route:
  enabled: true
  host: "homepage.apps.your-cluster.com"
  tls:
    enabled: true
    termination: edge

# Security contexts (no fixed UIDs)
podSecurityContext: {}
securityContext:
  runAsNonRoot: true
  allowPrivilegeEscalation: false

# Environment variables
extraEnv:
  - name: HOMEPAGE_ALLOWED_HOSTS
    value: "*"
```

### Disconnected/Air-Gapped Deployment

For disconnected environments:

1. **Mirror the image** to your internal registry:
```bash
skopeo copy docker://ghcr.io/gethomepage/homepage:latest \
  docker://your-registry.com/homepage:latest
```

2. **Update values** to use your registry:
```yaml
image:
  registry: your-registry.com
  repository: homepage
  tag: latest
```

3. **Install with custom registry**:
```bash
helm install homepage ./homepage-openshift \
  --set image.registry=your-registry.com \
  --set image.repository=homepage
```

## Accessing Homepage

After installation, the application will be available via the OpenShift Route:
```bash
# Get the route URL
oc get route homepage -o jsonpath='{.spec.host}'
```

## Troubleshooting

### Permission Issues
If you encounter RBAC errors:
```bash
# Check if ClusterRole is created
oc get clusterrole | grep homepage

# Verify ServiceAccount permissions
oc describe clusterrolebinding | grep homepage
```

### Security Context Issues
OpenShift automatically assigns UIDs, so avoid setting:
- `runAsUser`
- `runAsGroup`
- `fsGroup`

### Route Not Working
Check route status:
```bash
oc get route homepage
oc describe route homepage
```

## Customization

### Adding Custom Background Images

#### Method 1: Using ConfigMap (Recommended for OpenShift)

1. **Create a ConfigMap with your background image**:
```bash
oc create configmap homepage-backgrounds --from-file=/path/to/your/background.jpg
```

2. **Update values to use ConfigMap**:
```yaml
volumes:
  - name: config
    configMap:
      name: "{{ include \"homepage.fullname\" . }}-config"
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
```

3. **Update background path in settings**:
```yaml
config:
  settings: |
    background:
      image: /backgrounds/your-background.jpg
      blur: sx
      saturate: 50
      brightness: 50
      opacity: 20
```

#### Method 2: Using HostPath (For development)

```yaml
volumes:
  - name: backgrounds
    hostPath:
      path: /path/to/your/backgrounds
      type: Directory

volumeMounts:
  - name: backgrounds
    mountPath: "/app/public/backgrounds"
    readOnly: true
```

#### Method 3: Using PVC (Persistent Volume)

```yaml
volumes:
  - name: backgrounds
    persistentVolumeClaim:
      claimName: homepage-backgrounds-pvc

volumeMounts:
  - name: backgrounds
    mountPath: "/app/public/backgrounds"
    readOnly: true
```

### Service Configuration

The chart includes three pre-configured service sections:

1. **Services** - Main operational tools
2. **Developer Tools** - Documentation and team resources  
3. **ArgoCD Instances** - Multiple deployment environments

Edit the URLs in `values-openshift.yaml`:

```yaml
config:
  services: |
    ---
    - Services:
        - VLAN Manager:
            href: http://your-vlan-manager.local:8000
            description: Network VLAN management tool
            icon: mdi-network
        
        - Cluster Navigator:
            href: http://your-navigator.local:8001
            description: OpenShift cluster navigation tool
            icon: mdi-compass-outline
```

### Theme and Visual Configuration

The chart includes enhanced visual features:

```yaml
config:
  settings: |
    theme: dark
    color: slate
    background: 
      image: /backgrounds/your-background.jpg
      blur: sx          # none, sm, md, lg, xl, 2xl, 3xl
      saturate: 50      # 0-100
      brightness: 50    # 0-100
      opacity: 20       # 0-100
    layout:
      Services:
        style: row
        columns: 4
        equalHeight: true
    headerStyle: underlined  # boxed, underlined
    cardBlur: md            # none, sm, md, lg, xl
```