# qwen-code Docker image for pre-AVX2 CPUs (Mac Pro 2007 / Xeon 5xxx)

Runs [qwen-code](https://github.com/QwenLM/qwen-code) in Docker on machines
whose CPUs lack AVX2 — including the Mac Pro 2007 and Intel Xeon 5xxx series,
which cannot execute Node 22 binaries.

## What it does differently

| Problem | Fix |
|---|---|
| Node 22 requires AVX2 | Uses `node:20-bookworm-slim` with `--ignore-engines` |
| `qwen-code` npm package missing `tiktoken_bg.wasm` | Installs `tiktoken` separately and copies the WASM into the bundle |
| Headless container crashes on `xdg-open` (browser auth) | Stub `xdg-open` that exits cleanly |
| Default auth requires PAIC enterprise CAS login | Bakes `~/.qwen/settings.json` with `selectedType: openai` so it uses `OPENAI_*` env vars instead |

## Build

```bash
docker build -t qwenlm/qwen-code:latest .
```

Pin a specific npm release:

```bash
docker build --build-arg QWEN_CODE_VERSION=0.0.5 -t qwenlm/qwen-code:0.0.5 .
```

Use a different Node base (must be < 22 for pre-AVX2):

```bash
docker build --build-arg NODE_IMAGE=node:20-bookworm-slim -t qwenlm/qwen-code:latest .
```

## Run

Pass your OpenAI-compatible endpoint via environment variables:

```bash
docker run --rm \
  -v /path/to/repo:/workspace \
  -e OPENAI_BASE_URL=https://your-ocabra-endpoint/v1 \
  -e OPENAI_API_KEY=your-token \
  -e OPENAI_MODEL=qwen2.5-coder-32b \
  qwenlm/qwen-code:latest \
  "your prompt here"
```

The entrypoint is `qwen -p`, so the last argument is the prompt.
