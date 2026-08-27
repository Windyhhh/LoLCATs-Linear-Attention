<div align="center">

# 🧠 LoLCATs-Linear-Attention

### Distilling 405B LLMs into O(n) linear-attention variants.

Low-rank linear-attention Transformer with CUDA kernels — distill large models into fast linear-attention transformers.

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.9+-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.0-EE4C2C?logo=pytorch&logoColor=white)](https://pytorch.org/)
[![CUDA](https://img.shields.io/badge/CUDA-Kernels-76B900?logo=nvidia&logoColor=white)](https://developer.nvidia.com/cuda-zone)

</div>

---

**LoLCATs-Linear-Attention** distills a **405B LLM** into an **O(n) linear-attention** variant with low-rank projections — including CUDA kernels for efficient training. Config-driven distillation experiments are included.

> [!NOTE]
> 中文项目：低秩线性注意力 Transformer——将 405B LLM 蒸馏为 O(n) 线性注意力变体，含 CUDA 内核。

---

## Quickstart

```bash
git clone https://github.com/Windyhhh/LoLCATs-Linear-Attention.git
cd LoLCATs-Linear-Attention

pip install -r requirements.txt

# Run a config-driven distillation experiment
# see docs/START_HERE.md for setup
```

Experiment configs (distillation on alpaca-clean with xent / MSE losses) live in `lolcats-main/configs/experiment/`.

---

## Features

- **O(n) linear attention** — low-rank linear-attention Transformer.
- **Distillation** — from a 405B teacher into a linear-attention student.
- **CUDA kernels** — efficient custom kernels.
- **Config-driven** — reproducible YAML experiments.

---

## Project Structure

```
LoLCATs-Linear-Attention/
├── lolcats-main/              # core repo (models, configs, assets)
│   └── configs/experiment/    # distillation YAML configs
├── docs/                      # START_HERE, experiment guide, troubleshooting
├── PROJECT_STRUCTURE.md
└── README.md
```

---

## License

MIT — free to use, modify and distribute.
