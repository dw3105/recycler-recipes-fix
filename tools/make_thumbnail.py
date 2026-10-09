#!/usr/bin/env python3
"""Generate the original 144x144 Recycler Recipes Fix thumbnail."""
import struct
import sys
import zlib

W = H = 144
BG = (24, 35, 42, 255)
GREEN = (88, 190, 132, 255)
DARK = (24, 35, 42, 255)
WHITE = (245, 250, 247, 255)

pixels = [[BG for _ in range(W)] for _ in range(H)]

def disk(cx, cy, radius, color):
    for y in range(max(0, cy-radius), min(H, cy+radius+1)):
        for x in range(max(0, cx-radius), min(W, cx+radius+1)):
            if (x-cx)**2 + (y-cy)**2 <= radius**2:
                pixels[y][x] = color

def line(x0, y0, x1, y1, color, width=8):
    dx, dy = x1-x0, y1-y0
    steps = max(abs(dx), abs(dy), 1)
    for i in range(steps+1):
        x = round(x0 + dx*i/steps)
        y = round(y0 + dy*i/steps)
        disk(x, y, width//2, color)

# Bold circular arrows, drawn as two curved arrow strokes.
for cx, cy, start, end in ((72, 72, -150, 35), (72, 72, 30, 215)):
    pts=[]
    for deg in range(start, end+1, 5):
        import math
        a=math.radians(deg)
        pts.append((round(cx+43*math.cos(a)), round(cy+43*math.sin(a))))
    for a,b in zip(pts, pts[1:]): line(*a,*b,GREEN,9)
# Arrowheads at the ends of both arc strokes.
line(107, 48, 119, 49, GREEN, 9); line(107, 48, 111, 61, GREEN, 9)
line(37, 96, 25, 95, GREEN, 9); line(37, 96, 33, 83, GREEN, 9)
# Central check mark.
line(53, 73, 67, 87, WHITE, 10)
line(67, 87, 94, 57, WHITE, 10)

def chunk(kind, data):
    return struct.pack('>I', len(data)) + kind + data + struct.pack('>I', zlib.crc32(kind+data) & 0xffffffff)

raw=b''.join(b'\x00'+bytes(channel for px in row for channel in px) for row in pixels)
png=b'\x89PNG\r\n\x1a\n'
png+=chunk(b'IHDR', struct.pack('>2I5B', W, H, 8, 6, 0, 0, 0))
png+=chunk(b'IDAT', zlib.compress(raw, 9))
png+=chunk(b'IEND', b'')
out=sys.argv[1] if len(sys.argv)>1 else 'thumbnail.png'
with open(out,'wb') as f: f.write(png)
