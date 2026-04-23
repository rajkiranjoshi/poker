# Bench / debug pod: vLLM CLI (`vllm bench`, etc.) against the in-cluster gateway — no GPU required.
ARG PYTHON_VERSION=3.12
FROM python:${PYTHON_VERSION}-bookworm

ARG VLLM_VERSION=0.19.1
ARG JUST_VERSION=1.50.0
# Docker BuildKit sets TARGETARCH (e.g. amd64, arm64). Default matches kubectl below.
ARG TARGETARCH=amd64
ENV PIP_NO_CACHE_DIR=1 \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl jq \
    && rm -rf /var/lib/apt/lists/*

# kubectl (optional: discover gateway / services from inside the pod)
RUN curl -fsSL "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

# just (https://github.com/casey/just) — command runner for Justfiles in /workspace
RUN set -eux; \
    case "${TARGETARCH}" in \
        amd64) rust_arch=x86_64 ;; \
        arm64) rust_arch=aarch64 ;; \
        *) echo "unsupported TARGETARCH=${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-${rust_arch}-unknown-linux-musl.tar.gz" \
        | tar -xz -C /usr/local/bin just; \
    chmod +x /usr/local/bin/just; \
    just --version

RUN pip install --upgrade pip && \
    pip install "vllm[bench]==${VLLM_VERSION}"

WORKDIR /workspace
CMD ["sleep", "infinity"]
