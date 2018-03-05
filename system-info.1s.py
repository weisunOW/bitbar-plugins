#!/usr/bin/env PYTHONIOENCODING=UTF-8 /usr/local/bin/python3

import psutil as pu
import time

def humanise(byte_size=0, suffix='B'):
    size = byte_size
    for unit in ['', 'K', 'M', 'G', 'T', 'P', 'E', 'Z']:
        if abs(size) < 1024.0:
            return "%3.1f %s%s" % (size, unit, suffix)
        size /= 1024.0

    return ".1f %s%s" % (size, 'Y', suffix)

def load_color(load=0.0):
    if load >= 90:
        return "red"
    elif load >= 80:
        return "orange"
    elif load >= 60:
        return "gold"
    elif load >= 30:
        return "green"
    else:
        return "blue"

def brief_info():
    cpu = pu.cpu_percent(interval=None)
    vmem = pu.virtual_memory()
    mem = vmem.percent
    return cpu, mem

def network_bandwidth():
    rx = pu.net_io_counters().bytes_recv
    tx = pu.net_io_counters().bytes_sent
    return rx, tx

def system_info():
    pu.cpu_percent(interval=None)
    rx, tx = network_bandwidth()
    time.sleep(1.0)
    new_rx, new_tx = network_bandwidth()
    cpu, mem = brief_info()
    rx = humanise(new_rx - rx, suffix='bps')
    tx = humanise(new_tx - tx, suffix='bps')
    bandwidth = "⬇ {}, ⬆ {}".format(rx, tx)
    return cpu, mem, bandwidth

def load_per_core():
    loads = pu.cpu_percent(interval=None, percpu=True)
    average_load = sum(loads) / len(loads)
    result = ["CPU: {:3.1f}% | color={}".format(average_load, load_color(average_load))]
    for i, l in enumerate(loads):
        result.append("\n--Core {}: {}% | color={}".format(i, l, load_color(l)))
    return ''.join(result)

def mem_percent():
    vmem = pu.virtual_memory()
    mem_load = ["Memory: {}% | color={}".format(vmem.percent, load_color(vmem.percent))]
    mem_load.append("\n--{}{}".format("Total: ", humanise(vmem.total)))
    mem_load.append("\n--{}{}".format("Available: ", humanise(vmem.available)))
    mem_load.append("\n--{}{}".format("Used: ", humanise(vmem.used)))
    mem_load.append("\n--{}{}".format("Free: ", humanise(vmem.free)))
    mem_load.append("\n--{}{}".format("Active: ", humanise(vmem.active)))
    mem_load.append("\n--{}{}".format("Inactive: ", humanise(vmem.inactive)))
    mem_load.append("\n--{}{}".format("Wired:", humanise(vmem.wired)))
    return ''.join(mem_load)

cpu, mem, bandwidth = system_info()
cpu = "CPU: {}%".format(cpu)
mem = "MEM: {}%".format(mem)
bandwidth = "Bandwidth: {}".format(bandwidth)
print("{0:^}  ❙  {1:^}  ❙  {2:^}".format(cpu, mem, bandwidth))
print("---")
print(load_per_core())
print(mem_percent())
print("Network")
print("Refresh | refresh=true")
