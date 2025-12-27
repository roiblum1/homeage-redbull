# Assets for Homepage Dashboard

This directory contains static assets for the Homepage dashboard deployment.

## 📁 Directory Structure

```
assets/
├── backgrounds/          # Background images
│   ├── v1-background-dark.jpg
│   ├── v2-background-dark.jpg  
│   ├── v3-background-dark.jpg
│   └── v4-background-dark.jpg
├── icons/               # Custom icons (if any)
└── README.md           # This file
```

## 🎨 Background Images

The `backgrounds/` directory contains dark-themed background images optimized for the Homepage dashboard:

- **v1-background-dark.jpg** - Alternative dark background
- **v2-background-dark.jpg** - Alternative dark background  
- **v3-background-dark.jpg** - Alternative dark background
- **v4-background-dark.jpg** - Default dark background (recommended)

### Using Background Images

#### For Docker/Podman Deployment:
```yaml
# docker-compose.yml
volumes:
  - ./assets/backgrounds:/app/public/backgrounds:ro
```

#### For OpenShift/Kubernetes:
```bash
# Create ConfigMap with background images
oc create configmap homepage-backgrounds \
  --from-file=v4-background-dark.jpg=assets/backgrounds/v4-background-dark.jpg \
  --from-file=v3-background-dark.jpg=assets/backgrounds/v3-background-dark.jpg
```

#### Update Settings:
```yaml
# In settings.yaml or values file
background:
  image: /backgrounds/v4-background-dark.jpg
  blur: sx
  saturate: 50
  brightness: 50
  opacity: 20
```

## 🔒 Air-Gapped Deployments

For disconnected environments, these local assets ensure:
- ✅ No external image dependencies
- ✅ Consistent visual experience
- ✅ Fast loading times
- ✅ Reliable availability

## 📐 Image Specifications

All background images are optimized for:
- **Dark themes** - High contrast, professional appearance
- **Multiple resolutions** - Responsive design support  
- **Low file size** - Fast loading
- **Blur compatibility** - Work well with CSS blur effects

## 🎯 Customization

To add your own background images:

1. **Add image files** to `assets/backgrounds/`
2. **Update ConfigMap** (Kubernetes) or **volume mount** (Docker)
3. **Modify settings** to reference new image path
4. **Test blur effects** with your custom images

---

Ready to create stunning dashboards! 🚀