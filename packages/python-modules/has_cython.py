import sys
try:
    from Cython.Build import cythonize
    print("cython found", file=sys.stderr)
    print(1)
except Exception:
    print("no cython found", file=sys.stderr)
    print(0)
