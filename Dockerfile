# Bench / debug pod: vLLM CLI (`vllm bench`, etc.) against the in-cluster gateway — no GPU required.
ARG PYTHON_VERSION=3.12
FROM python:${PYTHON_VERSION}-bookworm

ARG VLLM_VERSION=0.19.1
ENV PIP_NO_CACHE_DIR=1 \
    DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl jq \
    && rm -rf /var/lib/apt/lists/*

# kubectl (optional: discover gateway / services from inside the pod)
RUN curl -fsSL "https://dl.k8s.io/release/$(curl -fsSL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    -o /usr/local/bin/kubectl && chmod +x /usr/local/bin/kubectl

RUN pip install --upgrade pip && \
    pip install "vllm[bench]==${VLLM_VERSION}"

WORKDIR /workspace
CMD ["sleep", "infinity"]
