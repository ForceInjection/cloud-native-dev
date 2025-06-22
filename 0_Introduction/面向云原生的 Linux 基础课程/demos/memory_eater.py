import time

# 分配大约 150MB 内存
data = []
for i in range(150):
    data.append('x' * 1024 * 1024)  # 1MB per iteration
    print(f"Allocated {i+1} MB")
    time.sleep(0.1)

print("Memory allocation complete")
time.sleep(60)