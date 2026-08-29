<div align="center">

# 线性注意力大模型蒸馏 | LoLCATs-Linear-Attention

### Linear attention to break LLM compute bottlenecks.

Efficient linear-attention training across three stages — long-context, low-latency, resource-friendly.

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/Python-3.9+-3776AB?logo=python&logoColor=white)](https://www.python.org/)
[![PyTorch](https://img.shields.io/badge/PyTorch-2.0-EE4C2C?logo=pytorch&logoColor=white)](https://pytorch.org/)

</div>

---

**LoLCATs-Linear-Attention** explores **linear attention** as a breakthrough for LLM compute bottlenecks — enabling long-context processing without OOM and low-latency inference, through a **three-stage training pipeline**.

> [!NOTE]
> 中文项目：LoLCATs 线性注意力——突破大模型计算瓶颈，三阶段训练，长文本低显存、低延迟推理。

---

## Features

- **Linear attention** — sub-quadratic attention to avoid OOM on long text.
- **Three-stage training** — staged pipeline for stable convergence.
- **Low-latency inference** — suitable for chat / real-time translation.
- **Resource-friendly** — trainable on limited GPU budgets.

---

## Quickstart

```bash
git clone https://github.com/Windyhhh/LoLCATs-Linear-Attention.git
cd LoLCATs-Linear-Attention

pip install -r requirements.txt

# run stage-1 training
python scripts/train_stage1.py
# evaluate
python scripts/evaluate.py
```

Experiment steps and config templates are in `docs/`.

---

## Project Structure

```
LoLCATs-Linear-Attention/
├── lolcats-main/           # model & training code
├── scripts/                # training / eval scripts
├── docs/                   # experiment guide, config templates
└── lolcats_blog.md         # technical deep-dive
```

---

## License

MIT — free to use, modify and distribute.
