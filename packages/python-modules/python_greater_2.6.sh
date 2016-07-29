#!/bin/sh

exec python -c '
import sys

if sys.hexversion < 0x02060000:
    print(0)
else:
    print(1)
'
