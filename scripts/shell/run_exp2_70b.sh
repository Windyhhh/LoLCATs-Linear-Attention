#!/bin/bash

# LoLCATs 实验二：Llama 3.1 70B 线性化
# 预计耗时：18 小时

cd /d/900/lolcats-main

echo "=========================================="
echo "LoLCATs 实验二：Llama 3.1 70B 线性化"
echo "=========================================="
echo ""

# 使用 Llama 3.1 70B + Hedgehog 特征映射 + LoLCATs 线性+滑动窗口注意力
# 使用块训练策略处理大模型

echo "开始运行实验..."
echo ""

python distill_llama.py \
  --model_config distill_llama3_1_70b_lk_smd_wtk64_fd64_w01 \
  --distill_config distill_redpajama_xent0_mse1000_lr1e-2 \
  --finetune_config finetune_lora_qkvo_redpajama \
  --eval_config eval_redpajama \
  --lk_zero_init \
  --verbose \
  --seed 0 \
  --replicate 0 \
  --checkpoint_dir ./checkpoints/exp2_70b \
  --results_dir ./results/exp2_70b \
  --no_wandb \
  --huggingface_token "${HF_TOKEN:-}"

echo ""
echo "=========================================="
echo "实验二（70B）完成！"
echo "=========================================="

