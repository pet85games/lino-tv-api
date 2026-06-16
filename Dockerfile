# LINO TV Unified Content API
# Production Dockerfile

FROM node:22-alpine

# Set working directory
WORKDIR /app

# Install dependencies for native modules
RUN apk add --no-cache python3 make g++ curl

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Copy source code
COPY src/ ./src/
COPY public/ ./public/
COPY .env.example .env.example

# Create logs directory
RUN mkdir -p logs

# Create non-root user
RUN addgroup -g 1001 -S linotv && \
    adduser -S linotv -u 1001 -G linotv && \
    chown -R linotv:linotv /app

USER linotv

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1

# Labels
LABEL name="LINO TV Unified Content API"
LABEL version="1.0.0"
LABEL description="Centralized backend for LINO TV Android TV application"
LABEL maintainer="LINO TV Team"

# Start server
CMD ["node", "src/server.js"]
