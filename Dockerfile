# Build stage
FROM dart:3.9 AS builder

WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Get dependencies
RUN dart pub get

# Copy application code (includes public and assets)
COPY . .

# Ensure public and assets directories exist (create if missing)
RUN mkdir -p public assets

# Verify directories exist (for debugging)
RUN ls -la public/ 2>/dev/null || echo "public directory is empty or missing"
RUN ls -la assets/ 2>/dev/null || echo "assets directory is empty or missing"

# Build release binary
RUN dart compile exe lib/main.dart -o bin/server

# Runtime stage
FROM dart:3.9

WORKDIR /app

# Copy the compiled binary from builder
COPY --from=builder /app/bin/server /app/bin/server

# Create directories for public, assets, and migrations (they will be mounted as volumes)
# We don't copy them into the image to save space - they're mounted from host
RUN mkdir -p ./public ./assets ./migrations

# Expose port
EXPOSE 8080

# Run the app
CMD ["/app/bin/server"]
