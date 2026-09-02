from __future__ import annotations

import math
import subprocess
import sys
import tkinter as tk
from datetime import datetime
from pathlib import Path
from tkinter import scrolledtext


VAULT = Path(__file__).resolve().parents[1]
ACCENT = "#13e5cf"
ACCENT_DIM = "#136e67"
BG = "#030b10"
PANEL = "#08161d"
PANEL_2 = "#0b2026"
TEXT = "#c4fff7"
MUTED = "#78a9aa"
GOLD = "#ffc857"

NODES = {
    "MERKEZ": ("Atlas.md", "ATLAS / MERKEZ"),
    "PROJELER": ("nodes/Projects.md", "PROJELER"),
    "KARİYER": ("nodes/Career-Abroad.md", "KARİYER & YURTDIŞI"),
    "FİKİRLER": ("nodes/Ideas.md", "FİKİRLER"),
    "BİLGİ": ("nodes/Knowledge.md", "BİLGİ TABANI"),
    "GÜNLÜK": ("daily", "OTURUM GÜNLÜKLERİ"),
}


class AtlasApp(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("ATLAS — EmreOS")
        self.geometry("1480x900")
        self.minsize(1000, 650)
        self.configure(bg=BG)
        self.selected = "MERKEZ"
        self.phase = 0.0
        self._build()
        self.load_node("MERKEZ")
        self.animate_orb()

    def _build(self) -> None:
        top = tk.Frame(self, bg=BG, height=72)
        top.pack(fill="x", padx=26, pady=(18, 0))
        top.pack_propagate(False)
        tk.Label(top, text="ATLAS", fg=ACCENT, bg=BG, font=("Segoe UI Semibold", 24), anchor="w").pack(side="left")
        tk.Label(top, text="EMREOS  •  İKİNCİ BEYİN", fg=MUTED, bg=BG, font=("Consolas", 10)).pack(side="left", padx=17)
        self.status = tk.Label(top, text="● SİSTEM HAZIR", fg="#63ffae", bg=BG, font=("Consolas", 10))
        self.status.pack(side="right")

        body = tk.Frame(self, bg=BG)
        body.pack(fill="both", expand=True, padx=26, pady=18)
        body.grid_columnconfigure(0, weight=0)
        body.grid_columnconfigure(1, weight=1)
        body.grid_columnconfigure(2, weight=1)
        body.grid_rowconfigure(0, weight=1)

        self.nav = tk.Frame(body, bg=PANEL, highlightbackground=ACCENT_DIM, highlightthickness=1, width=240)
        self.nav.grid(row=0, column=0, sticky="nsew", padx=(0, 16))
        self.nav.grid_propagate(False)
        tk.Label(self.nav, text="BAĞLAM AĞI", fg=MUTED, bg=PANEL, font=("Consolas", 10)).pack(anchor="w", padx=18, pady=(20, 14))
        for key in NODES:
            button = tk.Button(self.nav, text=key, command=lambda k=key: self.load_node(k),
                               anchor="w", relief="flat", bd=0, padx=18, pady=10,
                               bg=PANEL, activebackground=PANEL_2, fg=TEXT,
                               activeforeground=ACCENT, font=("Segoe UI", 11))
            button.pack(fill="x", padx=7, pady=2)
        tk.Frame(self.nav, bg=ACCENT_DIM, height=1).pack(fill="x", padx=18, pady=20)
        tk.Button(self.nav, text="↻  İNDEKSİ DERLE", command=self.compile_index, anchor="w",
                  relief="flat", bd=0, padx=18, pady=9, bg=PANEL, fg=GOLD,
                  activebackground=PANEL_2, activeforeground=GOLD).pack(fill="x", padx=7)
        tk.Button(self.nav, text="+  OTURUM KAYDET", command=self.save_session, anchor="w",
                  relief="flat", bd=0, padx=18, pady=9, bg=PANEL, fg=ACCENT,
                  activebackground=PANEL_2, activeforeground=ACCENT).pack(fill="x", padx=7)

        center = tk.Frame(body, bg=BG)
        center.grid(row=0, column=1, sticky="nsew", padx=(0, 16))
        self.canvas = tk.Canvas(center, bg=BG, highlightthickness=0)
        self.canvas.pack(fill="both", expand=True)
        self.canvas.bind("<Configure>", lambda _e: self.draw_orb())
        self.canvas.bind("<Button-1>", lambda _e: self.load_node("MERKEZ"))

        right = tk.Frame(body, bg=PANEL, highlightbackground=ACCENT_DIM, highlightthickness=1)
        right.grid(row=0, column=2, sticky="nsew")
        right.grid_rowconfigure(2, weight=1)
        tk.Label(right, text="AKTİF BAĞLAM", fg=MUTED, bg=PANEL, font=("Consolas", 10)).grid(row=0, column=0, sticky="w", padx=20, pady=(20, 5))
        self.title_label = tk.Label(right, text="", fg=ACCENT, bg=PANEL, font=("Segoe UI Semibold", 18), anchor="w")
        self.title_label.grid(row=1, column=0, sticky="ew", padx=20, pady=(0, 12))
        self.content = scrolledtext.ScrolledText(right, wrap="word", bg=PANEL, fg=TEXT,
            insertbackground=ACCENT, relief="flat", bd=0, font=("Segoe UI", 11), padx=20, pady=8)
        self.content.grid(row=2, column=0, sticky="nsew")
        self.content.configure(state="disabled")
        self.meta = tk.Label(right, text="", fg=MUTED, bg=PANEL, font=("Consolas", 9), anchor="w")
        self.meta.grid(row=3, column=0, sticky="ew", padx=20, pady=(8, 18))

        footer = tk.Label(self, text="ATLAS LOCAL CORE  /  CODEX + OPENCODE UYUMLU  /  VERİLER SADECE BU VAULT'TA",
                          fg=MUTED, bg=BG, font=("Consolas", 9), anchor="w")
        footer.pack(fill="x", padx=28, pady=(0, 14))

    def draw_orb(self) -> None:
        c = self.canvas
        c.delete("all")
        w, h = max(c.winfo_width(), 20), max(c.winfo_height(), 20)
        x, y = w / 2, h / 2
        pulse = 6 * math.sin(self.phase)
        rings = [(330 + pulse, "#0d4c51"), (252 - pulse, "#0b7475"), (172 + pulse, ACCENT)]
        for size, color in rings:
            c.create_oval(x-size, y-size, x+size, y+size, outline=color, width=2)
        for offset in (0, math.pi, math.pi / 2, math.pi * 1.5):
            angle = self.phase + offset
            r = 212
            px, py = x + math.cos(angle) * r, y + math.sin(angle) * r
            c.create_oval(px-5, py-5, px+5, py+5, fill=ACCENT, outline="")
        c.create_oval(x-92, y-92, x+92, y+92, fill="#061a20", outline=ACCENT, width=2)
        c.create_text(x, y-16, text="ATLAS", fill=ACCENT, font=("Segoe UI Semibold", 27))
        c.create_text(x, y+18, text="EMRE'NİN MERKEZİ", fill=MUTED, font=("Consolas", 10))
        c.create_text(x, y+43, text=datetime.now().strftime("%d.%m.%Y  %H:%M"), fill=TEXT, font=("Consolas", 10))
        c.create_text(x, y+250, text="Merkeze dönmek için halkalara tıkla", fill=MUTED, font=("Segoe UI", 10))

    def animate_orb(self) -> None:
        self.phase += 0.055
        self.draw_orb()
        self.after(45, self.animate_orb)

    def load_node(self, key: str) -> None:
        self.selected = key
        relative, title = NODES[key]
        if relative == "daily":
            files = sorted((VAULT / "daily").glob("*.md"), reverse=True)
            path = files[0] if files else VAULT / "daily"
        else:
            path = VAULT / relative
        try:
            text = path.read_text(encoding="utf-8-sig")
        except Exception as error:
            text = f"Bu bağlam henüz okunamadı.\n\n{error}"
        self.title_label.configure(text=title)
        self.content.configure(state="normal")
        self.content.delete("1.0", "end")
        self.content.insert("1.0", text)
        self.content.configure(state="disabled")
        self.meta.configure(text=f"KAYNAK  /  {path.relative_to(VAULT)}")
        self.status.configure(text="● BAĞLAM YÜKLENDİ", fg="#63ffae")

    def run_atlas(self, action: str) -> None:
        command = ["powershell", "-ExecutionPolicy", "Bypass", "-NoProfile", "-File",
                   str(VAULT / ".atlas" / "atlas.ps1"), action]
        try:
            subprocess.run(command, cwd=VAULT, check=True, capture_output=True, text=True)
            self.status.configure(text="● İŞLEM TAMAMLANDI", fg="#63ffae")
            self.load_node(self.selected)
        except Exception as error:
            self.status.configure(text="● İŞLEM HATASI", fg="#ff6579")
            self.meta.configure(text=str(error))

    def compile_index(self) -> None:
        self.run_atlas("Compile")

    def save_session(self) -> None:
        self.run_atlas("Save")


if __name__ == "__main__":
    AtlasApp().mainloop()
