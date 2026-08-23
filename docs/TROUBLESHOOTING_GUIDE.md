# LoLCATs 故障排除指南

## 🔴 关键错误及解决方案

### 1. triton.ops 导入错误 ⚠️ 最常见

**错误信息**:
```
ModuleNotFoundError: No module named 'triton.ops'
```

**原因**: torch.cuda 初始化时检查 triton.__spec__，如果为 None 会报错

**解决方案**:
在 `distill_llama.py` 最开头添加补丁（见 COMPLETE_EXPERIMENT_STEPS.md）

**验证方法**:
```bash
python -c "import torch; print('✅ torch 导入成功')"
```

---

### 2. CUDA 显存不足

**错误信息**:
```
RuntimeError: CUDA out of memory
```

**原因**: 模型太大或批大小设置过大

**解决方案**:
```yaml
# 方案1：减少批大小
batch_size: 1  # 已是最小值

# 方案2：增加梯度累积步数
gradient_accumulation_steps: 16  # 从 8 增加到 16

# 方案3：启用梯度检查点
gradient_checkpointing: true

# 方案4：使用 8-bit 量化
load_in_8bit: true
```

---

### 3. seen_tokens 属性不存在

**错误信息**:
```
AttributeError: 'DynamicCache' object has no attribute 'seen_tokens'
```

**原因**: transformers 版本过旧

**解决方案**:
```bash
pip install --upgrade transformers==4.36.0
```

---

### 4. 模型下载失败

**错误信息**:
```
OSError: Can't load model. Model not found on huggingface.co
```

**原因**: 
- HF token 无效
- 未接受模型使用条款
- 网络连接问题

**解决方案**:
```bash
# 1. 检查 token
huggingface-cli login

# 2. 接受条款
# 访问: https://huggingface.co/meta-llama/Meta-Llama-3-8B

# 3. 测试连接
python -c "from transformers import AutoModel; AutoModel.from_pretrained('meta-llama/Meta-Llama-3-8B')"
```

---

### 5. 内存不足 (CPU)

**错误信息**:
```
MemoryError: Unable to allocate memory
```

**原因**: CPU 内存不足

**解决方案**:
```bash
# 检查可用内存
free -h

# 清理缓存
rm -rf ~/.cache/huggingface/hub/*

# 使用 device_map='cpu' 分散到 CPU
```

---

## 🟡 常见问题

### Q1: 训练速度很慢怎么办?

**原因**: 
- GPU 利用率低
- 数据加载瓶颈
- 模型太大

**解决方案**:
```bash
# 1. 检查 GPU 使用率
watch -n 1 nvidia-smi

# 2. 增加 num_workers
num_workers: 4

# 3. 启用混合精度训练
mixed_precision: bf16
```

### Q2: 训练中断如何恢复?

**解决方案**:
```bash
# 脚本会自动从最新检查点恢复
python scripts/python/smart_experiment_runner.py 8b

# 或手动指定检查点
python distill_llama.py \
  --resume_from_checkpoint ./checkpoints/exp1_8b/checkpoint-100
```

### Q3: 如何监控训练进度?

**解决方案**:
```bash
# 查看日志
tail -f logs/exp1_8b.log

# 查看 GPU 状态
watch -n 1 nvidia-smi

# 查看进程
ps aux | grep distill_llama

# 查看检查点
ls -lh checkpoints/exp1_8b/
```

### Q4: 如何中断训练?

**解决方案**:
```bash
# 方法1：Ctrl+C (会保存检查点)
# 在终端按 Ctrl+C

# 方法2：杀死进程
pkill -f distill_llama.py

# 方法3：使用 tmux
tmux send-keys -t lolcats C-c
```

### Q5: 如何修改学习率?

**解决方案**:
编辑配置文件 `configs/experiment/distill_alpaca_clean_xent0_mse1000_lr1e-2.yaml`:
```yaml
lr: 0.01  # 修改这里
```

---

## 🟢 性能优化

### 1. 启用混合精度训练
```yaml
mixed_precision: bf16
```

### 2. 启用梯度检查点
```yaml
gradient_checkpointing: true
```

### 3. 增加梯度累积
```yaml
gradient_accumulation_steps: 16
```

### 4. 使用 Flash Attention
```yaml
use_flash_attention: true
```

---

## 📊 诊断命令

```bash
# 检查 PyTorch 版本
python -c "import torch; print(torch.__version__)"

# 检查 CUDA 可用性
python -c "import torch; print(torch.cuda.is_available())"

# 检查 GPU 信息
nvidia-smi

# 检查 transformers 版本
python -c "import transformers; print(transformers.__version__)"

# 检查 triton 版本
python -c "import triton; print(triton.__version__)"

# 测试模型加载
python -c "from transformers import AutoModel; AutoModel.from_pretrained('meta-llama/Meta-Llama-3-8B')"
```

---

## 📞 获取帮助

1. 检查日志文件: `logs/exp1_8b.log`
2. 查看错误堆栈跟踪
3. 运行诊断命令
4. 参考 COMPLETE_EXPERIMENT_STEPS.md

---

**最后更新**: 2025-11-13

