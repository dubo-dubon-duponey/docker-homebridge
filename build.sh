#!/usr/bin/env bash

# linux/arm/v6 is not supported for lack of a node image
IMAGE_OWNER="${IMAGE_OWNER:-dubodubonduponey}"
IMAGE_NAME="${IMAGE_NAME:-homebridge}"
IMAGE_VERSION="${IMAGE_VERSION:-v1}"
PLATFORMS="${PLATFORMS:-linux/amd64,linux/arm64,linux/arm/v7}"

export DOCKER_CLI_EXPERIMENTAL=enabled
docker buildx create --name "$IMAGE_NAME"
docker buildx use "$IMAGE_NAME"
docker buildx build --platform "$PLATFORMS" -t "$IMAGE_OWNER/$IMAGE_NAME:$IMAGE_VERSION" --push .
