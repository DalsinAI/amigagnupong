#!/usr/bin/env python3
"""Pong's picture for its GlowIcons (art/gnupong.png), drawn here:
upstream has none. A dark screen, the paddle of three # at the bottom and
the ball (an O) on its way up from it, its trail dotted behind.
64 x 64, RGBA, solid or see-through.
    python3 amiga/icons/draw_art.py amiga/icons/art
Pure Python. GPL-2.0-or-later, Copyright (c) 2026 AmiCradle Team."""
import struct, sys, zlib
from pathlib import Path

W = H = 64
INK = (16, 18, 22, 255)


def png(px, path):
    raw = b"".join(b"\0" + bytes(v for p in row for v in p) for row in px)
    def chunk(t, d):
        return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xffffffff)
    Path(path).write_bytes(b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", W, H, 8, 6, 0, 0, 0))
                           + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))


def draw():
    px = [[(0, 0, 0, 0)] * W for _ in range(H)]
    def rect(x0, y0, x1, y1, c):
        for y in range(max(0, y0), min(H, y1)):
            for x in range(max(0, x0), min(W, x1)):
                px[y][x] = c
    def disc(cx, cy, r, c):
        for y in range(H):
            for x in range(W):
                if (x - cx) ** 2 + (y - cy) ** 2 <= r * r:
                    px[y][x] = c
    green = (60, 220, 90, 255)
    rect(2, 4, 62, 60, INK)             # the console
    rect(2, 4, 62, 6, (90, 90, 100, 255))
    rect(16, 50, 40, 55, green)         # the paddle
    for i in range(4):                  # the ball's trail
        disc(30 + i * 5, 44 - i * 7, 1, (120, 120, 130, 255))
    disc(52, 14, 6, (240, 240, 240, 255))
    disc(52, 14, 3, INK)                # the O
    return px


if __name__ == "__main__":
    out = Path(sys.argv[1] if len(sys.argv) > 1 else "amiga/icons/art")
    out.mkdir(parents=True, exist_ok=True)
    png(draw(), out / "gnupong.png")
