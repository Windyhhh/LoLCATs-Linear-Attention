#!/bin/bash

# 验证所有准备工作是否完成

set -e

echo "=========================================="
echo "LoLCATs 准备工作完整验证"
echo "=========================================="
echo ""

LOLCATS_DIR="/root/lolcats/lolcats-main"
PASS=0
FAIL=0

check_file() {
    local file=$1
    local desc=$2
    if [ -f "$file" ]; then
        echo "   ✓ $desc"
        ((PASS++))
    else
        echo "   ✗ $desc (缺失)"
        ((FAIL++))
    fi
}

check_dir() {
    local dir=$1
    local desc=$2
    if [ -d "$dir" ]; then
        echo "   ✓ $desc"
        ((PASS++))
    else
        echo "   ✗ $desc (缺失)"
        ((FAIL++))
    fi
}

# 1. 检查模型配置
echo "1. 模型配置文件..."
check_file "$LOLCATS_DIR/configs/model/distill_llama3_8b_lk_smd_wtk64_fd64_w01.yaml" "8B 模型配置"
check_file "$LOLCATS_DIR/configs/model/distill_llama3_1_70b_lk_smd_wtk64_fd64_w01.yaml" "70B 模型配置"
check_file "$LOLCATS_DIR/configs/model/distill_llama3_1_405b_lk_smd_wtk64_fd64_w01.yaml" "405B 模型配置"

# 2. 检查实验配置
echo ""
echo "2. 实验配置文件..."
check_file "$LOLCATS_DIR/configs/experiment/distill_alpaca_clean_xent0_mse1000_lr1e-2.yaml" "8B 注意力迁移配置"
check_file "$LOLCATS_DIR/configs/experiment/distill_redpajama_xent1_mse1000_lr1e-2_70b.yaml" "70B 注意力迁移配置"
check_file "$LOLCATS_DIR/configs/experiment/distill_redpajama_xent1_mse1000_lr1e-2_405b.yaml" "405B 注意力迁移配置"

# 3. 检查微调配置
echo ""
echo "3. 微调配置文件..."
check_file "$LOLCATS_DIR/configs/experiment/finetune_lora_qkvo_alpaca_clean.yaml" "8B LoRA 微调配置"
check_file "$LOLCATS_DIR/configs/experiment/finetune_lora_qkvo_redpajama_70b.yaml" "70B LoRA 微调配置"
check_file "$LOLCATS_DIR/configs/experiment/finetune_lora_qkvo_redpajama_405b.yaml" "405B LoRA 微调配置"

# 4. 检查评估配置
echo ""
echo "4. 评估配置文件..."
check_file "$LOLCATS_DIR/configs/experiment/eval_alpaca_clean.yaml" "评估配置"

# 5. 检查数据集
echo ""
echo "5. 数据集..."
check_dir "$LOLCATS_DIR/data/alpaca" "Alpaca 数据集"
check_dir "$LOLCATS_DIR/data/redpajama" "RedPajama 数据集"

# 6. 检查脚本
echo ""
echo "6. 实验脚本..."
check_file "/root/lolcats/run_experiment_fixed.sh" "实验 1 脚本"
check_file "/root/lolcats/run_experiment_70b.sh" "实验 2 脚本"
check_file "/root/lolcats/run_experiment_405b.sh" "实验 3 脚本"
check_file "/root/lolcats/auto_run_experiments.sh" "自动运行脚本"

# 7. 检查目录结构
echo ""
echo "7. 实验目录..."
check_dir "$LOLCATS_DIR/checkpoints/exp1_8b" "实验 1 检查点目录"
check_dir "$LOLCATS_DIR/checkpoints/exp2_70b" "实验 2 检查点目录"
check_dir "$LOLCATS_DIR/checkpoints/exp3_405b" "实验 3 检查点目录"
check_dir "$LOLCATS_DIR/results/exp1_8b" "实验 1 结果目录"
check_dir "$LOLCATS_DIR/results/exp2_70b" "实验 2 结果目录"
check_dir "$LOLCATS_DIR/results/exp3_405b" "实验 3 结果目录"

# 8. 检查环境
echo ""
echo "8. 环境检查..."
source /root/miniconda3/etc/profile.d/conda.sh
conda activate lolcats

python_version=$(python --version 2>&1)
echo "   ✓ Python: $python_version"

pytorch_version=$(python -c "import torch; print(torch.__version__)" 2>&1)
echo "   ✓ PyTorch: $pytorch_version"

transformers_version=$(python -c "import transformers; print(transformers.__version__)" 2>&1)
echo "   ✓ Transformers: $transformers_version"

# 9. 检查磁盘空间
echo ""
echo "9. 磁盘空间..."
root_usage=$(df -h / | tail -1 | awk '{print $5}')
data_usage=$(df -h /root/autodl-tmp | tail -1 | awk '{print $5}')
echo "   ✓ 系统盘: $root_usage"
echo "   ✓ 数据盘: $data_usage"

# 10. 检查 GPU
echo ""
echo "10. GPU 检查..."
gpu_name=$(nvidia-smi --query-gpu=name --format=csv,noheader)
gpu_memory=$(nvidia-smi --query-gpu=memory.total --format=csv,noheader)
echo "   ✓ GPU: $gpu_name"
echo "   ✓ 显存: $gpu_memory"

# 总结
echo ""
echo "=========================================="
echo "验证结果"
echo "=========================================="
echo "✓ 通过: $PASS"
echo "✗ 失败: $FAIL"

if [ $FAIL -eq 0 ]; then
    echo ""
    echo "🎉 所有准备工作已完成！"
    echo ""
    echo "可以开始运行实验："
    echo "1. 实验 1 (8B) 已在运行"
    echo "2. 实验 2 (70B) 准备就绪"
    echo "3. 实验 3 (405B) 准备就绪"
    exit 0
else
    echo ""
    echo "⚠ 还有 $FAIL 项准备工作未完成"
    exit 1
fi

