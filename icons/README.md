# Custom Icons Directory

This directory is for **custom icon files** (PNG, SVG) that aren't available in Material Design Icons.

## Current Status

**Empty** - All services currently use Material Design Icons (MDI) which are bundled in the Homepage image.

## When to Add Icons Here

Add custom icon files here if you need icons not available in MDI:

```yaml
# In services.yaml
- My Custom Service:
    icon: /icons/custom-service.png  # References file in this directory
```

## Supported Formats

- PNG (recommended for photos/complex graphics)
- SVG (recommended for logos/simple graphics)
- ICO (for favicons)

## Example Structure

```
icons/
├── custom-app.png
├── proprietary-tool.svg
└── internal-service.ico
```

## Best Practices

1. **Use MDI first**: Check https://pictogrammers.com/library/mdi/ before adding custom icons
2. **Optimize file size**: Compress PNG/SVG files for faster loading
3. **Naming**: Use lowercase with dashes (e.g., `my-service.png`)
4. **Size**: Icons should be at least 64x64px (128x128px recommended)

## For Baked Image Deployment

Custom icons in this directory are automatically included in the baked image via:

```dockerfile
# In Containerfile (already configured)
COPY config/ /app/config/
# Icons are copied as part of the project structure
```

## Current Project Uses

All icons are MDI (no custom icons needed):
- mdi-gitlab
- mdi-ship-wheel
- mdi-kubernetes
- mdi-network
- etc.

See [ICONS-OFFLINE.md](../ICONS-OFFLINE.md) for complete icon documentation.
