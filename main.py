#!/usr/bin/env python3
from datetime import datetime
import time
print(f"[{datetime.now()}] EvolveSpintronics v0.4 started")
spin_state = 0
for i in range(1,6):
    print(f"Cycle {i} | Spin: {spin_state} | Thinking...")
    time.sleep(0.5)
    spin_state = (spin_state + 1) % 3
    print(f"   → Evolved to spin {spin_state}")
print("Demo complete.")
