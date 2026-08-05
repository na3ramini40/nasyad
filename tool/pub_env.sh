#!/usr/bin/env bash
# Runflare pub/Flutter mirror — source before flutter/dart commands.
# Forces Runflare even if the shell has pub-azs or other mirrors configured.
# See .cursor/rules/pub-mirror.mdc
export PUB_HOSTED_URL="https://mirror-flutter.runflare.com"
export FLUTTER_STORAGE_BASE_URL="https://mirror-gcs.runflare.com"
