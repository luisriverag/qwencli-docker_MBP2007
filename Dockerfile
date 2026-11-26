# syntax=docker/dockerfile:1
# QwenLM/qwen-code coding agent, installed from npm (@qwen-code/cli).
#
# qwen-code declares Node.js >= 22 in its engine field; we use Node 20 with
# --ignore-engines so the image also runs on pre-AVX2 CPUs (Mac Pro 2007,
# Xeon 5xxx) that cannot execute Node 22 binaries.
#
# Build: docker compose build qwen-code
# Or:    docker build -t qwenlm/qwen-code:latest docker/qwen-code/
#
# To pin a release: set QWEN_CODE_REF to the npm version (e.g. 0.0.5).

ARG NODE_IMAGE=node:20-bookworm-slim

FROM ${NODE_IMAGE}
ARG QWEN_CODE_VERSION=latest
RUN apt-get update \
 && apt-get install -y --no-install-recommends git \
 && rm -rf /var/lib/apt/lists/* \
 && npm install -g --no-audit --no-fund --ignore-engines qwen-code@${QWEN_CODE_VERSION} \
 && npm install --prefix /tmp/tiktoken tiktoken \
 && find /tmp/tiktoken -name "tiktoken_bg.wasm" \
      -exec cp {} /usr/local/lib/node_modules/qwen-code/bundle/ \; \
 && rm -rf /tmp/tiktoken \
 && printf '#!/bin/sh\necho "xdg-open: $*" >&2\nexit 1\n' > /usr/local/bin/xdg-open \
 && chmod +x /usr/local/bin/xdg-open \
 && mkdir -p /root/.qwen \
 && printf '{"security":{"auth":{"selectedType":"openai"}}}\n' > /root/.qwen/settings.json
WORKDIR /workspace
# Marathon appends the prompt as the last argument: qwen -p <prompt>
ENTRYPOINT ["qwen", "-p"]
