#!/usr/bin/env python3
"""
监控实验1的进度
"""

import subprocess
import time
import re
from datetime import datetime

def get_latest_log_lines(log_file, num_lines=5):
    """获取日志文件的最后几行"""
    try:
        result = subprocess.run(
            ['tail', '-n', str(num_lines), log_file],
            capture_output=True,
            text=True,
            timeout=10
        )
        return result.stdout.strip().split('\n')
    except Exception as e:
        return [f"Error reading log: {e}"]

def extract_progress(line):
    """从日志行中提取进度信息"""
    # 提取梯度步数
    grad_step_match = re.search(r'gradient step: (\d+)', line)
    if grad_step_match:
        return int(grad_step_match.group(1))
    return None

def extract_loss(line):
    """从日志行中提取损失值"""
    loss_match = re.search(r'loss: ([\d.]+)', line)
    if loss_match:
        return float(loss_match.group(1))
    return None

def main():
    log_file = "/root/lolcats/lolcats-main/logs/exp1_8b.log"
    
    print("=" * 60)
    print("实验1进度监控")
    print("=" * 60)
    print(f"日志文件: {log_file}")
    print()
    
    last_grad_step = 0
    last_loss = None
    
    while True:
        try:
            lines = get_latest_log_lines(log_file, 10)
            
            # 查找最新的梯度步数和损失
            for line in reversed(lines):
                grad_step = extract_progress(line)
                loss = extract_loss(line)
                
                if grad_step is not None:
                    if grad_step != last_grad_step:
                        last_grad_step = grad_step
                        if loss is not None:
                            last_loss = loss
                        
                        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
                        print(f"[{timestamp}] Gradient Step: {grad_step:5d} | Loss: {loss:.4f}")
                    break
            
            # 检查是否完成
            for line in lines:
                if any(keyword in line for keyword in ['Evaluation complete', 'Training complete', 'Results saved', 'Final evaluation']):
                    print("\n✅ 实验1已完成！")
                    return
                if any(keyword in line for keyword in ['Error', 'Traceback', 'Exception']):
                    print(f"\n❌ 实验1出现错误: {line}")
                    return
            
            time.sleep(60)  # 每分钟检查一次
            
        except KeyboardInterrupt:
            print("\n⏹️  监控已停止")
            break
        except Exception as e:
            print(f"❌ 错误: {e}")
            time.sleep(60)

if __name__ == "__main__":
    main()

