# Build stage
FROM dart:3.9 AS builder

WORKDIR /app

# Copy pubspec files
COPY pubspec.* ./

# Get dependencies
RUN dart pub get

# Copy application code
COPY . .

# Build release binary
RUN dart compile exe lib/main.dart -o bin/server

# Runtime stage
FROM dart:3.9

WORKDIR /app

# Copy the compiled binary from builder
COPY --from=builder /app/bin/server /app/bin/server

# Copy public assets and resources
COPY --from=builder /app/public ./public
COPY --from=builder /app/assets ./assets

# Expose port
EXPOSE 8080

# Run the app
CMD ["/app/bin/server"]
