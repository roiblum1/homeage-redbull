# Icons in Disconnected Environments

This guide explains how to ensure icons work properly in air-gapped/disconnected environments.

## 🎨 Icon Types in Homepage

Homepage supports multiple icon sources:

1. **Material Design Icons (MDI)** - Prefix: `mdi-` (e.g., `mdi-gitlab`)
2. **Simple Icons** - Prefix: `si-` (e.g., `si-kubernetes`)
3. **Custom Icons** - Local PNG/SVG files in `/app/public/icons/`
4. **Service Icons** - Auto-fetched favicons (requires internet)

## 🔒 Air-Gapped Icon Configuration

### Current Configuration (Already Applied)

The project is configured to use **Material Design Icons (MDI)** which are bundled in the Homepage image:

**In `config/settings.yaml` and `homepage-openshift/values.yaml`:**
```yaml
# Force use of local icons (no CDN) for air-gapped environments
iconStyle: theme
```

This setting ensures:
- ✅ No external CDN calls for icon fonts
- ✅ Uses bundled MDI font from Homepage image
- ✅ All `mdi-*` icons work offline

### Verify Icons Are Bundled

The Homepage image (`ghcr.io/gethomepage/homepage:latest`) includes:

```bash
# Check if MDI icons are in the image
podman run --rm ghcr.io/gethomepage/homepage:latest \
  ls -la /app/public/fonts/ 2>/dev/null || \
  ls -la /app/node_modules/@mdi/ 2>/dev/null

# The icons are bundled in the application code
```

## 🧪 Testing Icons Offline

### Test Locally

```bash
# Start Homepage locally
podman-compose up -d

# Disconnect from internet (optional)
# sudo nmcli networking off

# Access http://localhost:3000
# All mdi-* icons should display correctly
```

### Test in Air-Gapped Environment

```bash
# Deploy to OpenShift
helm install homepage ./homepage-openshift

# Check pod logs for icon-related errors
oc logs -l app.kubernetes.io/name=homepage | grep -i "icon\|font\|mdi"

# Should see NO errors about failed icon/font loading
```

## 🔍 Troubleshooting Icon Issues

### Icons Not Showing

**Symptoms:**
- Empty boxes where icons should be
- Console errors about failed font loading
- Missing service icons

**Solutions:**

1. **Verify iconStyle setting:**
   ```bash
   # Check local config
   grep iconStyle config/settings.yaml

   # Should show: iconStyle: theme
   ```

2. **Check browser console (F12):**
   - Look for 404 errors on CDN URLs
   - Look for CORS errors
   - Should see NO external requests for icons

3. **Verify you're using MDI icons:**
   ```yaml
   # Correct - uses bundled MDI
   - GitLab:
       icon: mdi-gitlab

   # May not work offline - tries to fetch favicon
   - GitLab:
       icon: https://gitlab.com/favicon.ico
   ```

4. **Restart the pod/container:**
   ```bash
   # Local
   podman-compose restart

   # OpenShift
   oc rollout restart deployment/homepage
   ```

### Using Custom Icons (Optional)

If you need custom icons that aren't in MDI:

1. **Add PNG/SVG files to `icons/` directory:**
   ```bash
   # Example structure
   icons/
   ├── custom-app.png
   └── my-service.svg
   ```

2. **Reference in services.yaml:**
   ```yaml
   - My Service:
       icon: /icons/custom-app.png
   ```

3. **For baked image, the Containerfile already copies icons:**
   ```dockerfile
   # Icons are automatically included (directory exists in repo)
   COPY config/ /app/config/
   ```

### Alternative: Use Simple Icons

Homepage also bundles Simple Icons (`si-` prefix):

```yaml
# These work offline with iconStyle: theme
- GitLab:
    icon: si-gitlab
- Kubernetes:
    icon: si-kubernetes
- ArgoCD:
    icon: si-argo
```

**Find available icons:**
- MDI Icons: https://pictogrammers.com/library/mdi/
- Simple Icons: https://simpleicons.org/

## 📋 Complete MDI Icons Used in This Project

Current configuration uses these MDI icons (all work offline):

| Service | Icon | Code |
|---------|------|------|
| GitLab | 󰓂 | `mdi-gitlab` |
| ArgoCD | 󰡨 | `mdi-ship-wheel` |
| Confluence |  | `mdi-book-open-page-variant` |
| Grafana |  | `mdi-chart-line` |
| VLAN Manager | 󰛳 | `mdi-network` |
| Cluster Navigator | 󰍾 | `mdi-compass-outline` |
| OpenShift Console | ☸ | `mdi-kubernetes` |
| UCS Manager | 󰒋 | `mdi-server` |
| NetBox | 󰩟 | `mdi-ip-network` |
| OpenManage | 󰒍 | `mdi-server-network` |
| OneView | 󰒍 | `mdi-server-network` |

## 🚫 What NOT to Do in Air-Gapped Environments

❌ **Don't use external icon URLs:**
```yaml
# BAD - requires internet
icon: https://example.com/icon.png
```

❌ **Don't use service auto-icons without cache:**
```yaml
# MAY FAIL - tries to fetch favicon from service
icon: # empty (auto-fetch)
```

❌ **Don't use iconStyle: automatic:**
```yaml
# BAD for air-gapped
iconStyle: automatic  # tries CDN first
```

## ✅ Best Practices for Air-Gapped Icons

1. **Always use `mdi-` or `si-` prefixed icons**
2. **Set `iconStyle: theme` in settings**
3. **Test in disconnected environment before production**
4. **For custom icons, include PNG/SVG files in `/icons/` directory**
5. **Document which icons are used for future reference**

## 🔄 Updating Icons

If you need to change icons:

1. **Find replacement in MDI library:**
   - Browse: https://pictogrammers.com/library/mdi/
   - Use icon name with `mdi-` prefix

2. **Update config files:**
   ```bash
   # Edit local config
   vim config/services.yaml

   # Or edit Helm values
   vim homepage-openshift/values.yaml
   ```

3. **For baked image approach:**
   ```bash
   # Rebuild image with updated config
   ./build-image.sh
   podman push registry.internal.local/homepage-redbull:latest

   # Redeploy
   helm upgrade homepage ./homepage-openshift \
     -f homepage-openshift/values-baked-image.yaml
   ```

4. **For ConfigMap approach:**
   ```bash
   # Just upgrade Helm release
   helm upgrade homepage ./homepage-openshift
   ```

## 📚 Related Documentation

- [Main README](README.md)
- [Air-Gapped Deployment](homepage-openshift/AIRGAP-DEPLOYMENT.md)
- [Baked Image Guide](BAKED-IMAGE.md)
- [Homepage Icon Documentation](https://gethomepage.dev/latest/configs/services/#icons)
