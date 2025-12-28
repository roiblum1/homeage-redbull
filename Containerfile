# Homepage with Baked-in Configuration
# This image contains all configuration pre-loaded for easy deployment

FROM ghcr.io/gethomepage/homepage:latest

# Set metadata
LABEL maintainer="Red Bull Team" \
      description="Homepage dashboard with pre-configured services for Red Bull infrastructure" \
      version="1.0.0"

# Copy configuration files into the image
COPY config/services.yaml /app/config/services.yaml
COPY config/settings.yaml /app/config/settings.yaml
COPY config/widgets.yaml /app/config/widgets.yaml
COPY config/bookmarks.yaml /app/config/bookmarks.yaml

# Copy background images
COPY assets/backgrounds/ /app/public/backgrounds/

# Copy custom icons (if any exist in icons/ directory)
COPY icons/ /app/public/icons/

# Ensure proper permissions (Homepage runs as non-root user)
USER root
RUN chown -R 1000:1000 /app/config /app/public/backgrounds /app/public/icons && \
    chmod -R 755 /app/config /app/public/backgrounds /app/public/icons
USER 1000

# Environment variables (can be overridden at runtime)
ENV PUID=1000 \
    PGID=1000 \
    HOMEPAGE_ALLOWED_HOSTS="*" \
    NODE_TLS_REJECT_UNAUTHORIZED="0"

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/ || exit 1

# Use the default entrypoint from base image
