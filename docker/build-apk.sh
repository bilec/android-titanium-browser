#!/bin/bash
set -euo pipefail

PACKAGE_NAME=${1:?Usage: docker/build-apk.sh com.example.browser}
PACKAGE_PATTERN='^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$'

if ! [[ "$PACKAGE_NAME" =~ $PACKAGE_PATTERN ]]; then
  echo "Package name must be a dotted Android package name" >&2
  exit 1
fi

: "${LOCAL_TEST_JKS:?LOCAL_TEST_JKS must contain base64 local.properties}"
: "${STORE_TEST_JKS:?STORE_TEST_JKS must contain the base64 keystore}"

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
IMAGE_NAME=titanium-browser-builder

docker build --tag "$IMAGE_NAME" --file "$SCRIPT_DIR/Dockerfile" "$REPO_DIR"
exec docker run --rm \
  --shm-size=2g \
  --ulimit nofile=65536:65536 \
  --volume "$REPO_DIR:/workspace" \
  --env CHROME_PUBLIC_MANIFEST_PACKAGE="$PACKAGE_NAME" \
  --env LOCAL_TEST_JKS \
  --env STORE_TEST_JKS \
  "$IMAGE_NAME"
