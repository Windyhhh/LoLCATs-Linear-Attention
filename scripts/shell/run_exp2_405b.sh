#!/bin/bash

# LoLCATs 实验二：Llama 3.1 405B 线性化
# 预计耗时：21 小时

cd /d/900/lolcats-main

echo "=========================================="
echo "LoLCATs 实验二：Llama 3.1 405B 线性化"
echo "=========================================="
echo ""

# 使用 Llama 3.1 405B + Hedgehog 特征映射 + LoLCATs 线性+滑动窗口注意力
# 使用细粒度块训练策略（9层/块）处理超大模型

echo "开始运行实验..."
echo ""

python distill_llama.py \
  --model_config distill_llama3_1_405b_lk_smd_wtk64_fd64_w01 \
  --distill_config distill_redpajama_xent1_mse1000_lr1e-2 \
  --finetune_config finetune_lora_qkvo_redpajama_405b \
  --eval_config eval_redpajama \
  --lk_zero_init \
  --verbose \
  --seed 0 \
  --replicate 0 \
  --checkpoint_dir ./checkpoints/exp2_405b \
  --results_dir ./results/exp2_405b \
  --no_wandb \
  --huggingface_token "${HF_TOKEN:-}"

echo ""
echo "=========================================="
echo "实验二（405B）完成！"
echo "=========================================="

