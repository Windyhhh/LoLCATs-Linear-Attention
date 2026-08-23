# LoLCATs 完整实验复刻步骤

## 📖 目录
1. [环境准备](#环境准备)
2. [关键问题修复](#关键问题修复)
3. [配置文件准备](#配置文件准备)
4. [运行实验](#运行实验)
5. [故障排除](#故障排除)

---

## 环境准备

### 第1步：克隆项目
```bash
git clone https://github.com/lolcats/lolcats.git
cd lolcats
```

### 第2步：创建 Conda 环境
```bash
conda create -n lolcats python=3.10 -y
conda activate lolcats
```

### 第3步：安装 PyTorch
```bash
# GPU 版本 (CUDA 11.8)
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# 或 CPU 版本
pip install torch torchvision torchaudio
```

### 第4步：安装依赖包
```bash
pip install transformers==4.36.0
pip install peft==0.7.1
pip install bitsandbytes==0.41.1
pip install accelerate==0.24.1
pip install datasets==2.14.5
pip install triton==2.1.0
pip install tqdm
pip install pyyaml
```

### 第5步：获取 Hugging Face Token
1. 访问 https://huggingface.co/settings/tokens
2. 创建新 token (Read 权限)
3. 接受模型使用条款：
   - https://huggingface.co/meta-llama/Meta-Llama-3-8B
   - https://huggingface.co/meta-llama/Meta-Llama-3.1-70B
   - https://huggingface.co/meta-llama/Meta-Llama-3.1-405B

---

## 关键问题修复

### ⚠️ triton.ops 导入错误 (必须修复)

**问题**: `ModuleNotFoundError: No module named 'triton.ops'`

**原因**: torch.cuda 初始化时检查 triton.__spec__，如果为 None 会报错

**解决方案**: 在 `distill_llama.py` 最开头添加以下代码：

```python
# ============ 在文件最开头添加 ============
import sys
import types
import importlib.util

def _patch_triton_modules():
    """Create mock triton modules to prevent import errors"""
    try:
        import triton as real_triton
        if not hasattr(real_triton, 'ops'):
            triton_ops = types.ModuleType('triton.ops')
            triton_ops.__spec__ = importlib.util.spec_from_loader('triton.ops', loader=None)
            triton_ops.early_config_prune = lambda *args, **kwargs: None
            triton_ops.estimate_matmul_time = lambda *args, **kwargs: 0
            real_triton.ops = triton_ops
            sys.modules['triton.ops'] = triton_ops
        return
    except ImportError:
        pass
    
    # 如果 triton 未安装，创建完整的 mock
    triton = types.ModuleType('triton')
    triton.__spec__ = importlib.util.spec_from_loader('triton', loader=None)
    
    triton_ops = types.ModuleType('triton.ops')
    triton_ops.__spec__ = importlib.util.spec_from_loader('triton.ops', loader=None)
    triton_ops.early_config_prune = lambda *args, **kwargs: None
    triton_ops.estimate_matmul_time = lambda *args, **kwargs: 0
    
    triton.ops = triton_ops
    sys.modules['triton'] = triton
    sys.modules['triton.ops'] = triton_ops

_patch_triton_modules()

# 然后导入其他库
import torch
import transformers
# ... 其他导入
```

---

## 配置文件准备

### 必需的配置文件

#### 1. 模型配置 (`configs/model/distill_llama3_1_8b_lk_smd_wtk64_fd64_w01.yaml`)
```yaml
pretrained_model_name_or_path: "meta-llama/Meta-Llama-3-8B"
cache_dir: "/path/to/cache"
torch_dtype: bfloat16
device_map: auto
attention_type: lolcats_llama
window_size: 64
feature_dim: 64
```

#### 2. 蒸馏配置 (`configs/experiment/distill_alpaca_clean_xent0_mse1000_lr1e-2.yaml`)
```yaml
lr: 0.01
batch_size: 1
gradient_accumulation_steps: 8
num_epochs: 1
mse_factor: 1000
xent_factor: 0
```

#### 3. 微调配置 (`configs/experiment/finetune_lora_qkvo_alpaca_clean.yaml`)
```yaml
lr: 1e-4
lora_rank: 8
lora_alpha: 16
target_modules: ["q_proj", "k_proj", "v_proj", "o_proj"]
```

#### 4. 评估配置 (`configs/experiment/eval_alpaca_clean.yaml`)
```yaml
batch_size: 4
num_workers: 4
```

---

## 运行实验

### 方式1：自动化运行 (推荐)

```bash
# 8B 模型完整实验
python smart_experiment_runner.py 8b

# 70B 模型完整实验
python scripts/python/smart_experiment_runner.py 70b
```

### 方式2：手动运行各阶段

#### 阶段1：注意力蒸馏
```bash
python distill_llama.py \
  --model_config distill_llama3_1_8b_lk_smd_wtk64_fd64_w01 \
  --distill_config distill_alpaca_clean_xent0_mse1000_lr1e-2 \
  --checkpoint_dir ./checkpoints/exp1_8b
```

#### 阶段2：LoRA 微调
```bash
python distill_llama.py \
  --model_config distill_llama3_1_8b_lk_smd_wtk64_fd64_w01 \
  --finetune_config finetune_lora_qkvo_alpaca_clean \
  --checkpoint_dir ./checkpoints/exp1_8b
```

#### 阶段3：评估
```bash
python distill_llama.py \
  --model_config distill_llama3_1_8b_lk_smd_wtk64_fd64_w01 \
  --eval_config eval_alpaca_clean \
  --checkpoint_dir ./checkpoints/exp1_8b
```

---

## 故障排除

### 常见错误及解决方案

| 错误 | 原因 | 解决方案 |
|------|------|---------|
| `ModuleNotFoundError: triton.ops` | triton 模块问题 | 添加 triton 补丁 |
| `CUDA out of memory` | 显存不足 | 减少 batch_size 或增加梯度累积 |
| `seen_tokens not found` | transformers 版本过旧 | 更新到 4.36.0+ |
| `Model not found` | HF token 无效 | 检查 token 和网络连接 |

### 监控训练

```bash
# 查看日志
tail -f logs/exp1_8b.log

# 监控 GPU
watch -n 1 nvidia-smi

# 查看进程
ps aux | grep distill_llama
```

---

**最后更新**: 2025-11-13

