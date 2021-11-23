#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

import os
 
def main():
    print("LANG=%s" %os.environ.get("LANG"))
    print("LC_ALL=%s" %os.environ.get("LC_ALL"))
    print("ä")
 
if __name__ == '__main__':
    main()
