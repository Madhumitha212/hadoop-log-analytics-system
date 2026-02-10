#!/usr/bin/env python3
import sys
import re

# Regex: IP, timestamp, method, URI, protocol, status_code
log_pattern = re.compile(
    r'^(\S+) \S+ \S+ \[([^\]]+)\] "(\S+) ([^"]+) (\S+)" (\d{3})'
)

for line in sys.stdin:
    match = log_pattern.match(line)
    if not match:
        continue

    status_code = int(match.group(6))
    endpoint = match.group(4)

    # Normalize endpoint if needed
    endpoint = re.sub(r'/a\d+', '/a*', endpoint)

    if status_code >= 400:
        # Prefix keys for clarity
        print(f"STATUS_{status_code}\t1")
        print(f"{endpoint}\t1")

