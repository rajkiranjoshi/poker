# Poker

Container image for **bench and debug workloads** on [llm-d](https://llm-d.ai/) Kubernetes deployments ([source](https://github.com/llm-d/llm-d)). The pod stays idle (`sleep infinity`) so you can `kubectl exec` into it and run **vLLM CLI** commands—for example `vllm bench`—against your **in-cluster inference gateway**, without scheduling a GPU on this pod.

## What is in the image

- **Python** (default 3.12) on Debian Bookworm  
- **vLLM** (default 0.19.1) with the **`bench` extra** (`vllm[bench]`), so `vllm bench` matches the [benchmark CLI](https://docs.vllm.ai/en/latest/benchmarking/cli/) for that release  
- **kubectl** (Linux amd64), **curl**, **jq**—useful for discovering Services, gateways, or endpoints from inside the cluster  
- **Working directory**: `/workspace`

## Build

From the repository root:

```bash
docker build -t poker:latest .
```

Override versions with build args:

| Build arg        | Default | Description        |
|------------------|---------|--------------------|
| `PYTHON_VERSION` | `3.12`  | Base Python image |
| `VLLM_VERSION`   | `0.19.1` | Installed vLLM    |

Example:

```bash
docker build \
  --build-arg PYTHON_VERSION=3.12 \
  --build-arg VLLM_VERSION=0.19.1 \
  -t poker:latest .
```

## Use as a workload pod

1. Deploy this image as a long-running Pod or Job in the same namespace (or network context) as your llm-d gateway or model Serving workload.  
2. Exec into the container and run benchmarks or diagnostics, pointing `vllm` at your gateway URL or OpenAI-compatible endpoint as documented for your stack.

Example:

```bash
kubectl exec -it <pod-name> -- bash
# Inside the pod, e.g. discover services or run vllm bench per your gateway setup
```

The default command is `sleep infinity` so the container stays up until you stop the workload.

## Notes

- **`vllm bench` is not frozen at 0.6.6.** Subcommands, defaults, and supported workloads have expanded through 0.7–0.19. The bench implementation ships **inside** the `vllm` package, so **newer vLLM ⇒ newer bench**. Pin `VLLM_VERSION` to the release whose CLI and flags you want (often aligned with the vLLM version serving traffic).  
- This image is intended for **CPU-side** tooling (CLI, HTTP, kubectl); it does **not** require a GPU.  
- `kubectl` is built for **linux/amd64**; if you build or run on other architectures, align your cluster node architecture or adjust the install step in the Dockerfile.
