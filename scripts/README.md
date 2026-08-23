# 🐍 LoLCATs 项目脚本目录

## 📋 脚本概览

本文档目录包含了 LoLCATs 实验复刻项目的所有脚本文件。脚本按语言分类，便于管理和使用。

---

## 📁 目录结构

```
scripts/
├── python/           # Python 脚本
│   ├── smart_experiment_runner.py
│   └── monitor_exp1_progress.py
├── shell/            # Shell 脚本
│   ├── prepare_datasets.sh
│   ├── verify_all_preparations.sh
│   ├── run_exp2_405b.sh
│   └── run_exp2_70b.sh
└── README.md         # 本文件
```

---

## 🐍 Python 脚本

### 1. smart_experiment_runner.py ⭐⭐⭐
- **功能**: 智能实验运行器
- **用途**: 自动化运行完整的蒸馏和微调流程
- **特性**: 
  - 自动错误检测和修复
  - 进度跟踪和日志记录
  - 支持8B和70B模型
  - 自动重试机制
- **使用方法**:
  ```bash
  python scripts/python/smart_experiment_runner.py 8b
  python scripts/python/smart_experiment_runner.py 70b
  ```

### 2. monitor_exp1_progress.py ⭐⭐
- **功能**: 实验进度监控器
- **用途**: 实时监控实验1的运行状态
- **特性**:
  - 实时日志显示
  - 进度百分比计算
  - 错误检测和警告
  - 优雅的日志格式化
- **使用方法**:
  ```bash
  python scripts/python/monitor_exp1_progress.py
  ```

---

## 🔧 Shell 脚本

### 1. prepare_datasets.sh ⭐⭐
- **功能**: 数据集准备脚本
- **用途**: 下载和预处理训练数据集
- **包含数据集**:
  - Alpaca Clean 数据集
  - RedPajama 数据集
- **使用方法**:
  ```bash
  bash scripts/shell/prepare_datasets.sh
  ```

### 2. verify_all_preparations.sh ⭐⭐
- **功能**: 全面验证脚本
- **用途**: 检查环境配置和文件准备情况
- **检查项目**:
  - Python环境
  - CUDA配置
  - 模型文件
  - 配置文件
- **使用方法**:
  ```bash
  bash scripts/shell/verify_all_preparations.sh
  ```

### 3. run_exp2_405b.sh ⭐⭐⭐
- **功能**: 405B模型实验脚本
- **用途**: 运行Llama 3.1 405B模型的蒸馏实验
- **预估时间**: ~21小时
- **使用方法**:
  ```bash
  bash scripts/shell/run_exp2_405b.sh
  ```

### 4. run_exp2_70b.sh ⭐⭐⭐
- **功能**: 70B模型实验脚本
- **用途**: 运行Llama 3 70B模型的蒸馏实验
- **预估时间**: ~9-12小时
- **使用方法**:
  ```bash
  bash scripts/shell/run_exp2_70b.sh
  ```

---

## 🎯 推荐使用流程

### 流程1: 快速启动实验
```bash
# 1. 准备数据集
bash scripts/shell/prepare_d 2. 验证环境
bashatasets.sh

# scripts/shell/verify_all_preparations.sh

# 3. 运行实验
python scripts/python/smart_experiment_runner.py 8b

# 4. 监控进度
python scripts/python/monitor_exp1_progress.py
```

### 流程2: 特定模型实验
```bash
# 对于405B模型
bash scripts/shell/run_exp2_405b.sh

# 对于70B模型
bash scripts/shell/run_exp2_70b.sh
```

---

## ⚙️ 环境要求

### Python 脚本要求
- Python 3.8+
- torch >= 1.13.0
- transformers >= 4.30.0
- 其他依赖详见 `lolcats-main/environment.yaml`

### Shell 脚本要求
- Bash 4.0+
- curl (用于下载)
- wget 或 aria2c (可选，用于加速下载)

---

## 🔍 脚本特性

### 智能错误处理
- 所有Python脚本都包含错误检测和自动修复
- 支持断点续传和重试机制
- 详细的日志输出和进度显示

### 标准化输出
- 统一的日志格式
- 彩色输出支持 (在支持的终端中)
- 结构化的进度显示

### 灵活配置
- 支持命令行参数配置
- 配置文件热加载
- 环境变量支持

---

## 📊 性能统计

### 实验时间预估
- **8B模型**: 2.5小时 (蒸馏) + 1小时 (微调)
- **70B模型**: 9-12小时 (蒸馏) + 4-6小时 (微调)
- **405B模型**: ~21小时 (蒸馏) + ~8小时 (微调)

### 资源需求
- **8B**: 24GB GPU内存
- **70B**: 80GB GPU内存 (或2x40GB)
- **405B**: 大量GPU资源 (建议多卡部署)

---

**创建日期**: 2026-01-01  
**最后更新**: 2026-01-01  
**版本**: v2.0 (项目整理版)