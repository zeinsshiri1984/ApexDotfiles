#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update

apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  git \
  build-essential \
  pkg-config \
  tzdata

apt-get clean
rm -rf /var/lib/apt/lists/*
