# LoLCATs 配置文件模板

## 📁 配置文件结构

```
configs/
├── model/
│   ├── distill_llama3_1_8b_lk_smd_wtk64_fd64_w01.yaml
│   └── distill_llama3_1_70b_lk_smd_wtk64_fd64_w01.yaml
└── experiment/
    ├── distill_alpaca_clean_xent0_mse1000_lr1e-2.yaml
    ├── distill_alpaca_clean_xent0_mse1000_lr1e-4.yaml
    ├── finetune_lora_qkvo_alpaca_clean.yaml
    └── eval_alpaca_clean.yaml
```

---

## 模型配置模板

### 8B 模型配置
**文件**: `configs/model/distill_llama3_1_8b_lk_smd_wtk64_fd64_w01.yaml`

```yaml
# 模型基本信息
pretrained_model_name_or_path: "meta-llama/Meta-Llama-3-8B"
cache_dir: "/root/autodl-tmp/.cache/huggingface/hub"
torch_dtype: bfloat16
device_map: auto

# 注意力配置
attention_type: lolcats_llama
window_size: 64
feature_dim: 64
feature_map_type: softmax_dim

# 其他参数
load_in_8bit: false
load_in_4bit: false
```

### 70B 模型配置
**文件**: `configs/model/distill_llama3_1_70b_lk_smd_wtk64_fd64_w01.yaml`

```yaml
pretrained_model_name_or_path: "meta-llama/Meta-Llama-3.1-70B"
cache_dir: "/root/autodl-tmp/.cache/huggingface/hub"
torch_dtype: bfloat16
device_map: auto

attention_type: lolcats_llama
window_size: 64
feature_dim: 64
feature_map_type: softmax_dim

load_in_8bit: false
load_in_4bit: false
```

---

## 蒸馏配置模板

### 8B 蒸馏配置 (学习率 0.01)
**文件**: `configs/experiment/distill_alpaca_clean_xent0_mse1000_lr1e-2.yaml`

```yaml
# 学习率和优化器
lr: 0.01
weight_decay: 0.0
warmup_steps: 100

# 批处理
batch_size: 1
gradient_accumulation_steps: 8
num_epochs: 1

# 损失函数权重
mse_factor: 1000
xent_factor: 0

# 数据集
dataset_name: alpaca_clean
max_seq_length: 2048

# 检查点
save_steps: 100
eval_steps: 100
```

### 70B 蒸馏配置 (学习率 0.0001)
**文件**: `configs/experiment/distill_alpaca_clean_xent0_mse1000_lr1e-4.yaml`

```yaml
lr: 0.0001  # 比 8B 小 100 倍
weight_decay: 0.0
warmup_steps: 100

batch_size: 1
gradient_accumulation_steps: 8
num_epochs: 1

mse_factor: 1000
xent_factor: 0

dataset_name: alpaca_clean
max_seq_length: 2048

save_steps: 100
eval_steps: 100
```

---

## 微调配置模板

### LoRA 微调配置
**文件**: `configs/experiment/finetune_lora_qkvo_alpaca_clean.yaml`

```yaml
# LoRA 参数
lora_rank: 8
lora_alpha: 16
lora_dropout: 0.05
target_modules: ["q_proj", "k_proj", "v_proj", "o_proj"]

# 学习率和优化器
lr: 1e-4
weight_decay: 0.0
warmup_steps: 50

# 批处理
batch_size: 1
gradient_accumulation_steps: 8
num_epochs: 1

# 数据集
dataset_name: alpaca_clean
max_seq_length: 2048

# 检查点
save_steps: 50
eval_steps: 50
```

---

## 评估配置模板

### 评估配置
**文件**: `configs/experiment/eval_alpaca_clean.yaml`

```yaml
# 评估参数
batch_size: 4
num_workers: 4
max_samples: null

# 基准测试
benchmarks:
  - mmlu
  - arc
  - hellaswag

# 输出
output_dir: ./results
save_results: true
```

---

## 关键参数说明

### 学习率选择
- **8B 蒸馏**: 0.01 (较大的学习率)
- **70B 蒸馏**: 0.0001 (较小的学习率，避免过度更新)
- **微调**: 1e-4 (LoRA 微调的标准学习率)

### 损失函数权重
- **MSE 因子**: 1000 (蒸馏阶段，重点匹配注意力输出)
- **XEnt 因子**: 0 (蒸馏阶段不使用交叉熵)

### 梯度累积
- **梯度累积步数**: 8 (模拟更大的批大小)
- **实际批大小**: 1 × 8 = 8

### 序列长度
- **最大序列长度**: 2048 (Llama 模型的标准长度)

---

## 配置文件检查清单

- [ ] 模型配置文件存在
- [ ] 蒸馏配置文件存在
- [ ] 微调配置文件存在
- [ ] 评估配置文件存在
- [ ] 所有路径正确
- [ ] 学习率设置合理
- [ ] 批大小和梯度累积合理

---

**最后更新**: 2025-11-13

