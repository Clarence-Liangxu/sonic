#!/usr/bin/env python3

import sys
import re
from collections import defaultdict

def main(argument):
    benchmarks = defaultdict(list)
    order = []

    pattern = re.compile(r'^(Benchmark\w+.*?)\s+\d+\s+([\d.]+)\s+ns/op')

    try:
        with open(argument, 'r', encoding='utf-8') as f:
            for line in f:
                line = line.strip()
                if not line.startswith('Benchmark'):
                    continue
                match = pattern.match(line)
                if match:
                    name = match.group(1).strip()
                    value = float(match.group(2))
                    if name not in benchmarks:
                        order.append(name)
                    benchmarks[name].append(value)
    except FileNotFoundError:
        print("error, data.txt not found")
        return

    print("test name".ljust(40) + " mid 4(ns/op)".ljust(35) + "avg(ns/op)")
    print("-" * 75)

    for name in order:
        values = benchmarks[name]
        if len(values) != 8:
            print(f"warn: {name} only {len(values)} data (expect 8), continue")
            continue
        sorted_vals = sorted(values)
        middle_four = sorted_vals[2:6]
        avg = sum(middle_four) / 4.0

        vals_str = ', '.join(f"{v:.3f}" for v in middle_four)
        print(f"{name:<40}    {avg:.3f}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("usage: python3 cal.py <file>")
        sys.exit(1)

    argument = sys.argv[1]
    main(argument)