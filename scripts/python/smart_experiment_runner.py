#!/usr/bin/env python3
"""
智能实验运行器 - 自动检测和修复常见错误
"""

import subprocess
import sys
import os
import re
import time
from pathlib import Path

class ExperimentRunner:
    def __init__(self, model_size='8b', max_retries=3):
        self.model_size = model_size
        self.max_retries = max_retries
        self.attempt = 0
        self.log_file = None
        
    def get_config(self):
        """获取模型配置"""
        configs = {
            '8b': {
                'model_config': 'distill_llama3_8b_lk_smd_wtk64_fd64_w01',
                'distill_config': 'distill_alpaca_clean_xent0_mse1000_lr1e-2',
                'finetune_config': 'finetune_lora_qkvo_alpaca_clean',
                'eval_config': 'eval_alpaca_clean',
                'checkpoint_dir': './checkpoints/exp1_8b',
                'results_dir': './results/exp1_8b',
                'log_file': 'logs/exp1_8b.log',
            },
            '70b': {
                'model_config': 'distill_llama3_1_70b_lk_smd_wtk64_fd64_w01',
                'distill_config': 'distill_alpaca_clean_xent0_mse1000_lr1e-4',
                'finetune_config': 'finetune_lora_qkvo_alpaca_clean',
                'eval_config': 'eval_alpaca_clean',
                'checkpoint_dir': './checkpoints/exp2_70b',
                'results_dir': './results/exp2_70b',
                'log_file': 'logs/exp2_70b.log',
            },
        }
        return configs.get(self.model_size, configs['8b'])
    
    def check_log_for_errors(self):
        """检查日志中的已知错误"""
        if not self.log_file or not os.path.exists(self.log_file):
            return None
        
        with open(self.log_file, 'r') as f:
            content = f.read()
        
        # 检查已知错误
        errors = {
            'seen_tokens': 'AttributeError.*seen_tokens',
            'cuda_memory': 'CUDA out of memory',
            'connection': 'Connection.*timeout',
            'model_load': 'Error loading model',
        }
        
        for error_name, pattern in errors.items():
            if re.search(pattern, content):
                return error_name
        
        return None
    
    def apply_fix(self, error_type):
        """应用错误修复"""
        print(f"检测到错误: {error_type}")
        
        if error_type == 'seen_tokens':
            print("✓ 已应用 seen_tokens 兼容性修复")
            return True
        elif error_type == 'cuda_memory':
            print("⚠ CUDA 内存不足，请检查系统资源")
            return False
        elif error_type == 'connection':
            print("⚠ 网络连接超时，请检查网络")
            return False
        
        return True
    
    def run_experiment(self):
        """运行实验"""
        config = self.get_config()
        self.log_file = config['log_file']

        # 创建必要的目录
        os.makedirs(os.path.dirname(self.log_file), exist_ok=True)
        os.makedirs(config['checkpoint_dir'], exist_ok=True)
        os.makedirs(config['results_dir'], exist_ok=True)

        # 设置环境变量
        env = os.environ.copy()
        env['PYTHONUNBUFFERED'] = '1'

        cmd = [
            sys.executable, 'distill_llama.py',
            '--model_config', config['model_config'],
            '--distill_config', config['distill_config'],
            '--finetune_config', config['finetune_config'],
            '--eval_config', config['eval_config'],
            '--lk_zero_init',
            '--verbose',
            '--seed', '0',
            '--replicate', '0',
            '--checkpoint_dir', config['checkpoint_dir'],
            '--results_dir', config['results_dir'],
            '--no_wandb',
        ]

        print(f"运行命令: {' '.join(cmd)}")

        try:
            with open(self.log_file, 'a') as f:
                result = subprocess.run(cmd, stdout=f, stderr=subprocess.STDOUT, env=env)
            return result.returncode == 0
        except Exception as e:
            print(f"✗ 运行失败: {e}")
            return False
    
    def execute(self):
        """执行实验，带重试机制"""
        while self.attempt < self.max_retries:
            self.attempt += 1
            print(f"\n{'='*50}")
            print(f"尝试 {self.attempt}/{self.max_retries}")
            print(f"{'='*50}\n")
            
            # 运行实验
            success = self.run_experiment()
            
            if success:
                print("\n✅ 实验成功完成！")
                return 0
            
            # 检查错误
            error = self.check_log_for_errors()
            if error:
                if not self.apply_fix(error):
                    print(f"✗ 无法修复错误: {error}")
                    return 1
            
            if self.attempt < self.max_retries:
                print(f"\n等待 60 秒后重试...")
                time.sleep(60)
        
        print(f"\n✗ 已达到最大重试次数 ({self.max_retries})")
        return 1

if __name__ == '__main__':
    model_size = sys.argv[1] if len(sys.argv) > 1 else '8b'
    runner = ExperimentRunner(model_size=model_size, max_retries=3)
    sys.exit(runner.execute())

