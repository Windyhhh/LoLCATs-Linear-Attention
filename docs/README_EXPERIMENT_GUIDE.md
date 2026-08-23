# LoLCATs 实验复刻完整指南

## 📚 文档导航

本指南包含以下文档，请按顺序阅读：

1. **COMPLETE_EXPERIMENT_STEPS.md** ⭐ 必读
   - 完整的环境准备步骤
   - triton.ops 补丁详解
   - 配置文件准备
   - 运行实验的三种方式

2. **CONFIG_TEMPLATES.md**
   - 所有配置文件的模板
   - 参数说明和最佳实践
   - 8B 和 70B 配置对比

3. **TROUBLESHOOTING_GUIDE.md**
   - 常见错误及解决方案
   - 性能优化建议
   - 诊断命令

4. **CONFIG_TEMPLATES.md**
   - 实验时间表
   - 预期结果
   - 监控指标

5. **QUICK_REFERENCE.md**
   - 快速参考卡片
   - 常用命令
   - 一键启动脚本

---

## 🚀 快速开始 (5分钟)

### 第1步：环境准备
```bash
git clone https://github.com/lolcats/lolcats.git
cd lolcats
conda create -n lolcats python=3.10 -y
conda activate lolcats
pip install torch transformers peft bitsandbytes accelerate datasets triton
```

### 第2步：修复 triton.ops ⚠️ 重要
在 `distill_llama.py` 最开头添加补丁（见 COMPLETE_EXPERIMENT_STEPS.md）

### 第3步：运行实验
```bash
python scripts/python/smart_experiment_runner.py 8b
```

---

## 🎯 核心概念

### LoLCATs 是什么?
- **L**ow-rank **L**inear **A**ttention **T**ransformers
- 将 Softmax 注意力替换为线性注意力
- 保持模型性能同时降低计算复杂度

### 三个阶段
1. **蒸馏**: 训练线性注意力匹配 Softmax 输出
2. **微调**: 使用 LoRA 进行参数高效微调
3. **评估**: 在标准基准上评估性能

---

## 📊 关键参数速查

### 学习率
```
8B 蒸馏:  0.01
70B 蒸馏: 0.0001  (小 100 倍)
微调:     1e-4
```

### 损失权重
```
MSE 因子:  1000
XEnt 因子: 0
```

### 批处理
```
批大小:        1
梯度累积步数:  8
实际批大小:    8
```

---

## ⏱️ 时间预估

| 模型 | 蒸馏 | 微调 | 评估 | 总计 |
|------|------|------|------|------|
| 8B | 1h | 1h | 30m | **2.5h** |
| 70B | 6-8h | 2-3h | 30m | **9-12h** |

---

## 📈 预期结果

### 8B 模型
- MMLU: ~65.0 (原始 66.0, 保留 98.5%)
- ARC-c: ~58.0 (原始 59.0, 保留 98.3%)

### 70B 模型
- MMLU: ~67.7 (原始 68.0, 保留 99.6%)
- ARC-c: ~60.5 (原始 61.0, 保留 99.2%)

---

## 🔧 必需的修改

### 1. triton.ops 补丁 (distill_llama.py)
```python
import sys, types, importlib.util

def _patch_triton_modules():
    try:
        import triton as real_triton
        if not hasattr(real_triton, 'ops'):
            ops = types.ModuleType('triton.ops')
            ops.__spec__ = importlib.util.spec_from_loader('triton.ops', loader=None)
            ops.early_config_prune = lambda *a, **k: None
            ops.estimate_matmul_time = lambda *a, **k: 0
            real_triton.ops = ops
            sys.modules['triton.ops'] = ops
    except ImportError:
        pass

_patch_triton_modules()
```

### 2. 配置文件检查
- ✅ `configs/model/distill_llama3_1_8b_lk_smd_wtk64_fd64_w01.yaml`
- ✅ `configs/experiment/distill_alpaca_clean_xent0_mse1000_lr1e-2.yaml`
- ✅ `configs/experiment/finetune_lora_qkvo_alpaca_clean.yaml`
- ✅ `configs/experiment/eval_alpaca_clean.yaml`

---

## 🐛 常见错误

| 错误 | 解决方案 |
|------|---------|
| `ModuleNotFoundError: triton.ops` | 添加 triton 补丁 |
| `CUDA out of memory` | 减少 batch_size 或增加梯度累积 |
| `seen_tokens not found` | 更新 transformers 到 4.36.0+ |
| `Model not found` | 检查 HF token 和网络连接 |

---

## 📁 项目结构

```
lolcats/
├── distill_llama.py              # 主训练脚本 (需要添加补丁)
├── smart_experiment_runner.py    # 自动化实验运行器
├── configs/
│   ├── model/                    # 模型配置
│   └── experiment/               # 实验配置
├── src/
│   └── model/
│       ├── peft.py              # LoRA 实现
│       └── ...
├── checkpoints/                  # 模型检查点 (输出)
├── results/                      # 评估结果 (输出)
└── logs/                         # 训练日志 (输出)
```

---

## ✅ 检查清单

- [ ] 克隆项目
- [ ] 创建 Conda 环境
- [ ] 安装所有依赖
- [ ] 添加 triton 补丁
- [ ] 验证配置文件
- [ ] 获取 HF token
- [ ] 接受模型使用条款
- [ ] 运行实验
- [ ] 监控训练进度
- [ ] 验证结果

---

## 📞 获取帮助

1. 查看 TROUBLESHOOTING_GUIDE.md
2. 检查日志文件: `logs/exp1_8b.log`
3. 运行诊断命令 (见 TROUBLESHOOTING_GUIDE.md)
4. 查看错误堆栈跟踪

---

## 📝 版本信息

- **创建日期**: 2025-11-13
- **Python**: 3.10
- **PyTorch**: 2.0+
- **Transformers**: 4.36.0+
- **CUDA**: 11.8+

---

**祝你实验顺利！** 🎉

