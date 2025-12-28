#!/bin/bash
# Build script for Homepage with baked-in configuration

set -e

# Configuration
IMAGE_NAME="${IMAGE_NAME:-homepage-redbull}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
REGISTRY="${REGISTRY:-registry.internal.local}"

# Full image reference
FULL_IMAGE="${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"

echo "=========================================="
echo "Building Homepage with Baked Configuration"
echo "=========================================="
echo "Image: ${FULL_IMAGE}"
echo ""

# Build the image
echo "Building image..."
podman build -t "${IMAGE_NAME}:${IMAGE_TAG}" -f Containerfile .

# Tag for registry
echo "Tagging image for registry..."
podman tag "${IMAGE_NAME}:${IMAGE_TAG}" "${FULL_IMAGE}"

echo ""
echo "✅ Build complete!"
echo ""
echo "Image built and tagged as:"
echo "  - ${IMAGE_NAME}:${IMAGE_TAG} (local)"
echo "  - ${FULL_IMAGE} (registry)"
echo ""
echo "Next steps:"
echo "  1. Test locally:"
echo "     podman run -d -p 3000:3000 ${IMAGE_NAME}:${IMAGE_TAG}"
echo ""
echo "  2. Push to registry:"
echo "     podman push ${FULL_IMAGE}"
echo ""
echo "  3. Deploy to OpenShift:"
echo "     helm install homepage ./homepage-openshift \\"
echo "       --set image.registry=${REGISTRY} \\"
echo "       --set image.repository=${IMAGE_NAME} \\"
echo "       --set image.tag=${IMAGE_TAG}"
echo ""
