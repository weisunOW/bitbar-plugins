#!/usr/bin/env PYTHONIOENCODING=UTF-8 /usr/local/bin/python3

import time
import psutil

def humanise(bandwidth, suffix='bps'):
    bits = bandwidth
    for unit in ['', 'K', 'M', 'G', 'T', 'P', 'E', 'Z']:
        if abs(bits) < 1024.0:
            return "%3.1f%s%s" % (bits, unit, suffix)
        bits /= 1024.0

    return "%.1f%s%s" % (bits, 'Y', suffix)

def bandwidth():
    old_rx = psutil.net_io_counters().bytes_recv
    old_tx = psutil.net_io_counters().bytes_sent
    time.sleep(1)
    new_rx = psutil.net_io_counters().bytes_recv
    new_tx = psutil.net_io_counters().bytes_sent
    down = humanise(new_rx - old_rx)
    up = humanise(new_tx - old_tx)

    print("{} ⬇, {} ⬆".format(down, up))

bandwidth()
print("---")
print("Refresh | refresh=true")

