#!/usr/bin/env bash
# Runflare pub/Flutter mirror — local builds only.
# Source before flutter/dart commands on your machine.
# GitHub Actions uses default pub.dev hosts (no mirror env).
# See .cursor/rules/pub-mirror.mdc
export PUB_HOSTED_URL="https://mirror-flutter.runflare.com"
export FLUTTER_STORAGE_BASE_URL="https://mirror-gcs.runflare.com"
