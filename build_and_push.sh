docker buildx build --platform linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64 \
        -t linkease/ddnsto:3.1.0 \
        -f ./Dockerfile.architecture --push .