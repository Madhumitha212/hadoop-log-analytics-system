#!/usr/bin/env python3
import sys

# Read input line by line from STDIN
for line in sys.stdin:
    line = line.strip()
    words = line.split()
    for word in words:
        print(f"{word}\t1")
