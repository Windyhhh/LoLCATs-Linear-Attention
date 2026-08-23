# 🐱 LoLCATs: Low-rank Linear Attention Transformers | 低秩线性注意力 Transformer

> **Break the O(n²) wall of Transformers. Distill 405B models into linear-attention variants with CUDA-optimized kernels.**
>
> 打破 Transformer 的 O(n²) 计算壁垒。将 405B 大模型蒸馏为线性注意力变体，配备 CUDA 优化内核。

---

## 🌟 Why LoLCATs? | 为什么选择 LoLCATs？

Standard self-attention scales as **O(n²)** in both time and memory — a fundamental bottleneck for long-context LLMs. LoLCATs (**Lo**w-rank **L**inear **C**ompressible **A**ttention **T**ransformers) replaces quadratic attention with **linear-complexity attention** via low-rank kernel approximation, then distills knowledge from massive pretrained models (Llama 3 8B/70B/405B, Mistral 7B) into these efficient variants.

标准自注意力在时间和内存上均为 **O(n²)** 复杂度——这是长上下文大模型的根本瓶颈。LoLCATs 通过低秩核近似将二次注意力替换为**线性复杂度注意力**，再将海量预训练模型（Llama 3 8B/70B/405B、Mistral 7B）的知识蒸馏到这些高效变体中。

| Metric | Standard Attention | LoLCATs Linear Attention |
|--------|-------------------|--------------------------|
| Time Complexity | O(n²) | **O(n)** |
| Memory Complexity | O(n²) | **O(n)** |
| Long Context (32K+) | Prohibitive | **Feasible** |
| CUDA Kernel | Native | **Custom Optimized** |

---

## ✨ Key Features | 核心特性

- 🔥 **Linear Attention Kernels** — Multiple linear attention variants (TK, SW, T2R) with sliding-window extensions
- 🧪 **Knowledge Distillation Pipeline** — End-to-end distillation from Llama 3 / Mistral to linear-attention students
- ⚡ **CUDA-Optimized Implementations** — Custom CUDA kernels for causal attention with KV-cache support
- 📊 **Comprehensive Evaluation** — MMLU benchmark evaluation + lm-eval-harness integration
- 🎛️ **50+ Experiment Configs** — Pre-built YAML configs for 8B/70B/405B distillation, LoRA fine-tuning, and long-context training
- 🐳 **Reproducible Environment** — Conda environment.yaml + automated experiment runner

---

## 🏗️ Architecture | 架构设计

```
┌─────────────────────────────────────────────────────────────┐
│                    Teacher Model (Frozen)                    │
│         Llama 3 8B / 70B / 405B  |  Mistral 7B            │
│                    Standard O(n²) Attention                   │
└──────────────────────────┬──────────────────────────────────┘
                           │ Knowledge Distillation
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                   Student Model (Trainable)                   │
│    Linear Attention:  TK  |  SW  |  T2R  +  Sliding Window  │
│                    O(n) Complexity Attention                   │
└──────────────────────────┬──────────────────────────────────┘
                           │
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
      Cross-Entropy    Attention MSE    Feature Distill
        (Logits)        (QK Maps)       (Hidden States)
```

---

## 📁 Project Structure | 项目结构

```
LoLCATs-Linear-Attention/
├── distill_llama.py              # Main distillation script (with Triton patches)
├── environment.yaml               # Conda environment
├── setup.py                       # Package setup
├── LICENSE
│
├── configs/                       # 50+ experiment configurations
│   ├── base_*.yaml               # Base model configs (Llama 3, Mistral)
│   ├── distill_*.yaml            # Distillation configs (8B/70B/405B)
│   ├── finetune_lora_*.yaml      # LoRA fine-tuning configs
│   ├── eval_*.yaml               # Evaluation configs
│   └── distill_long_*.yaml       # Long-context training configs
│
├── csrc/                          # CUDA kernel implementations
│   ├── causal_attention_cuda.cu   # Optimized causal attention kernel
│   ├── causal_attention_kv_cuda.cu # KV-cache variant
│   ├── causal_attention.cpp       # C++ binding
│   └── causal_attention.py        # Python reference
│
├── linear_attention/              # Core linear attention modules
│   ├── linear_attention.py        # Base linear attention (22KB)
│   ├── linear_window_attention_sw.py     # Sliding-window variant
│   ├── linear_window_attention_tk.py     # TK variant
│   ├── linear_window_attention_tk_gen.py # TK generation
│   └── utils.py
│
├── src/                           # Model implementations
│   ├── models_huggingface.py      # HF-compatible models (33KB)
│   ├── models.py                  # Base model definitions
│   ├── modeling_llama.py          # Llama architecture
│   ├── modeling_mistral.py        # Mistral architecture
│   ├── peft.py                    # Parameter-efficient fine-tuning
│   ├── rotary.py                  # Rotary position embeddings
│   └── ...
│
├── lm_eval_harness/               # Evaluation toolkit
│   ├── eval_mmlu.py               # MMLU benchmark (24KB)
│   ├── eval_lm_harness.py         # lm-eval-harness integration
│   └── eval_lm_harness_big.py     # Large-model evaluation
│
├── demos/                         # Demo scripts
│   ├── demo_lolcats_hf.py         # HuggingFace demo (16KB)
│   ├── demo_8b.sh / demo_70b.sh / demo_405b.sh
│   └── benchmark_8b.sh            # Performance benchmark
│
├── data/                          # Dataset loaders
│   ├── alpaca_clean.py            # Alpaca-cleaned dataset
│   ├── alpaca_clean_instruct.py   # Instruction variant
│   ├── llama3.py                  # Llama 3 data format
│   └── packing.py                 # Sequence packing
│
├── scripts/                       # Automation scripts
│   ├── smart_experiment_runner.py # Automated experiment orchestrator
│   ├── monitor_exp1_progress.py   # Progress monitoring
│   ├── prepare_datasets.sh        # Dataset preparation
│   └── run_exp2_*.sh             # Multi-GPU experiment launchers
│
└── docs/                          # Documentation
    ├── START_HERE.md              # Quick start guide
    ├── COMPLETE_EXPERIMENT_STEPS.md # Full experiment walkthrough
    ├── CONFIG_TEMPLATES.md        # Configuration templates
    └── TROUBLESHOOTING_GUIDE.md  # Troubleshooting
```

---

## 🚀 Quick Start | 快速开始

### 1. Environment Setup | 环境配置

```bash
conda env create -f environment.yaml
conda activate lolcats
```

### 2. Run Distillation | 运行蒸馏

```bash
# 8B model distillation (recommended for single GPU)
python distill_llama.py --config configs/distill_llama3_1_8b_lk_smd_fd64.yaml

# Or use the automated experiment runner
python scripts/smart_experiment_runner.py 8b
```

### 3. Evaluate | 评估

```bash
python lm_eval_harness/eval_mmlu.py --model_path ./outputs/lolcats_8b
```

### 4. Demo | 演示

```bash
python demos/demo_lolcats_hf.py --model_path ./outputs/lolcats_8b
```

---

## 📊 Experiment Configurations | 实验配置

| Config | Teacher | Attention Type | Key Params |
|--------|---------|---------------|------------|
| `distill_llama3_1_8b_lk_smd_fd64.yaml` | Llama 3.1 8B | Linear (SMD) | feature_dim=64 |
| `distill_llama3_1_70b_lk_smd_wtk64_fd64_w01.yaml` | Llama 3.1 70B | Linear + TK | window=64, w=0.1 |
| `distill_llama3_1_405b_lk_smd_wtk64_fd64_w01.yaml` | Llama 3.1 405B | Linear + TK | window=64, w=0.1 |
| `distill_mistral_7b_lk_smd_fd64.yaml` | Mistral 7B | Linear (SMD) | feature_dim=64 |
| `finetune_lora_qkvo_alpaca_clean.yaml` | LoRA Fine-tune | QKVO LoRA | Alpaca-cleaned |
| `distill_long_llama3_1_8b_lk_smd_wsw64_fd64_w01.yaml` | Llama 3.1 8B | Long-context | sliding window=64 |

---

## 🔬 Technical Deep Dive | 技术深度解析

### Linear Attention Mechanism | 线性注意力机制

Standard attention: `Attention(Q,K,V) = softmax(QK^T/√d) V` → O(n²)

Linear attention replaces softmax with a kernel feature map `φ`:
`LinearAttention(Q,K,V) = (φ(Q) φ(K)^T) V / (φ(Q) φ(K)^T 1)` → O(n)

This project implements multiple kernel variants:
- **TK (Tk Kernel)**: Taylor expansion approximation
- **SW (Sliding Window)**: Local window + global linear
- **T2R**: Rank-2 tensor decomposition

### Knowledge Distillation | 知识蒸馏

Three complementary distillation losses:
1. **Cross-Entropy (Logits)**: Match output probability distributions
2. **Attention MSE**: Match QK attention maps layer-by-layer
3. **Feature Distillation**: Match hidden state representations

---

## 📈 Performance | 性能表现

- **8B distillation**: ~2.5 hours on single A100
- **70B distillation**: ~9-12 hours on multi-GPU
- **Linear attention speedup**: Up to **3-5x** on 32K+ context
- **Memory reduction**: Up to **70%** on long sequences

---

## 📝 Citation | 引用

If you use this code in your research, please cite:

```bibtex
@misc{lolcats2025,
  title={LoLCATs: Low-rank Linear Attention Transformers for Efficient Long-Context Language Models},
  year={2025}
}
```

---

## 📄 License | 许可证

MIT License — see [LICENSE](LICENSE) for details.

---

<div align="center">

**Built with ❤️ for efficient long-context AI**

[Report Bug](https://github.com/Windyhhh/LoLCATs-Linear-Attention/issues) · [Request Feature](https://github.com/Windyhhh/LoLCATs-Linear-Attention/issues)

</div>
