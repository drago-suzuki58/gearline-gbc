"""PyBoy test harness for GEARLINE."""
import os, sys, warnings
warnings.filterwarnings("ignore")
from pyboy import PyBoy

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHOTS = os.path.join(ROOT, "build", "shots")
os.makedirs(SHOTS, exist_ok=True)


def syms():
    d = {}
    for line in open(os.path.join(ROOT, "build", "gearline.sym")):
        line = line.split(";")[0].strip()
        if not line:
            continue
        a, n = line.split()
        d[n] = int(a.split(":")[1], 16)
    # RAM labels in fixed sections are not listed by rgblink: derive them from the source
    import re
    addr = None
    for line in open(os.path.join(ROOT, "src", "main.asm")):
        m = re.match(r'SECTION\s+"[^"]+",\s*(\w+)(?:\[\$([0-9A-Fa-f]+)\])?', line)
        if m:
            addr = int(m.group(2), 16) if (m.group(1).startswith("WRAM") and m.group(2)) else None
            continue
        if addr is None:
            continue
        m = re.match(r"(\w+):\s*(?:(ds)\s+(\d+)|(db)|(dw))?", line)
        if m:
            d[m.group(1)] = addr
            addr += int(m.group(3)) if m.group(2) else 1 if m.group(4) else 2 if m.group(5) else 0
    return d


class Game:
    def __init__(self, fresh=True):
        rom = os.path.join(ROOT, "gearline.gbc")
        if fresh:
            for ext in (".ram", ".gbc.ram"):
                p = os.path.join(ROOT, "gearline" + ext)
                if os.path.exists(p):
                    os.remove(p)
        self.pb = PyBoy(rom, window="null", sound_emulated=False)
        self.pb.set_emulation_speed(0)
        self.s = syms()
        self.m = self.pb.memory

    def tick(self, n=1):
        for _ in range(n):
            self.pb.tick(1, True)

    def press(self, btn, hold=3, wait=6):
        self.pb.button_press(btn)
        self.tick(hold)
        self.pb.button_release(btn)
        self.tick(wait)

    def shot(self, name, scale=3):
        img = self.pb.screen.image.convert("RGB")
        img = img.resize((img.width * scale, img.height * scale), 0)
        p = os.path.join(SHOTS, name + ".png")
        img.save(p)
        return p

    def rb(self, name, off=0):
        return self.m[self.s[name] + off]

    def rw(self, name, off=0):
        a = self.s[name] + off
        return self.m[a] | (self.m[a + 1] << 8)

    def wb(self, name, v, off=0):
        self.m[self.s[name] + off] = v

    def ww(self, name, v, off=0):
        a = self.s[name] + off
        self.m[a] = v & 255
        self.m[a + 1] = v >> 8

    def stock(self, item):
        return self.rw("wStock", item * 2)

    def set_stock(self, item, v):
        self.ww("wStock", v, item * 2)

    def cell(self, x, y):
        i = y * 32 + x
        return dict(terr=self.m[0xC000 + i], type=self.m[0xC400 + i], item=self.m[0xC800 + i],
                    data=self.m[0xCC00 + i], a=self.m[0xD000 + i], b=self.m[0xD400 + i])

    def goto(self, x, y):
        """move the cursor with the d-pad (no buttons held)"""
        for _ in range(80):
            cx, cy = self.rb("wCurX"), self.rb("wCurY")
            if (cx, cy) == (x, y):
                return
            if cx < x: self.press("right", 2, 2)
            elif cx > x: self.press("left", 2, 2)
            elif cy < y: self.press("down", 2, 2)
            elif cy > y: self.press("up", 2, 2)
        raise RuntimeError(f"goto failed {cx},{cy} -> {x},{y}")

    def terrain_map(self):
        ch = ".,*TwICKS"
        return ["".join(ch[self.m[0xC000 + y * 32 + x]] for x in range(32)) for y in range(32)]
