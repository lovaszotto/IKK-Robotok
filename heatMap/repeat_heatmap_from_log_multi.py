#!/usr/bin/env python3
"""
repeat_heatmap_from_log_multi.py
--------------------------------
- Több "Fájl neve:" blokkot dolgoz fel egy logból.
- A blokkhoz tartozó marker (., [, *, ?, !) sorokból hőtérképet generál.
- PNG-t ment az eredeti fájlnév alapján, státusz prefix-szel (ha van státusz sor a formában:
  [>>> Rendben<<<] / [>>> Gyanús<<<] / [>>> Másolt<<<]).
- (ÚJ) Minden képen jelmagyarázat ("Jelmagyarázat") jelenik meg.
- (Opc.) --make-pdf: a generált PNG-ket egyetlen PDF-be fűzi (fpdf2 szükséges).
- A PDF első oldala tartalomjegyzék (TOC), majd minden képnél cím + kép ugyanazon az oldalon.
- A hőtérképen a sorok (Y) és a karakterek (X) tengelye is mindig egész szám, Y legalább 1-től indul.
- Rácsvonalak (major grid) mindkét tengelyen.

Használat:
  python repeat_heatmap_from_log_multi.py --input feldolgozas.log --outdir ./heatmaps
  python repeat_heatmap_from_log_multi.py -i feldolgozas.log -o ./heatmaps --make-pdf --pdf-name osszes.pdf
"""

import sys
import argparse
import re
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import matplotlib.ticker as mticker
from matplotlib.patches import Patch

# PDF-hez szükséges csomagok (opcionális)
try:
    from PIL import Image
    from fpdf import FPDF  # fpdf2 szükséges!
    _PDF_OK = True
except Exception:
    _PDF_OK = False

# Jel → szín
COLOR_MAP = {
    '.': 'green',     # új sor
    '[': 'blue',      # első ismétlődés
    '*': 'skyblue',   # folytatódó ismétlés
    '?': 'orange',    # ≥350 karakter egyezés
    '!': 'red',       # ≥1250 karakter egyezés
}

FILENAME_PREFIX = "Fájl neve:"
# Státusz sor alakja: [>>> Rendben<<<]  vagy [>>> Gyanús<<<]  vagy [>>> Másolt<<<]
STATUS_RE = re.compile(r'^\[\s*>>>\s*(Rendben|Gyanús|Másolt)\s*<<<\s*\]$')

def sanitize_filename(name: str) -> str:
    name = name.strip().strip('"').strip("'")
    name = name.replace('\\', '_').replace('/', '_').replace(':', '_')
    return re.sub(r'[^\w.\-]+', '_', name)

def extract_blocks(text: str):
    blocks = []
    marker_re = re.compile(r'^[.\[\]\*\?!\s-]+$')
    current_lines = []
    current_name_original = None
    current_status = None

    for raw_line in text.splitlines():
        line = raw_line.rstrip('\n')

        if line.startswith(FILENAME_PREFIX):
            if current_name_original and current_lines:
                safe = sanitize_filename(current_name_original)
                blocks.append((current_name_original, safe, current_lines, current_status))
            current_name_original = line.split(FILENAME_PREFIX, 1)[1].strip()
            current_lines = []
            current_status = None
            continue

        m = STATUS_RE.match(line)
        if m:
            current_status = m.group(1)  # Rendben / Gyanús / Másolt
            continue

        if current_name_original and marker_re.match(line):
            if line.strip():
                current_lines.append(line)

    if current_name_original and current_lines:
        safe = sanitize_filename(current_name_original)
        blocks.append((current_name_original, safe, current_lines, current_status))

    return blocks

def encode_matrix(lines):
    max_len = max(len(line) for line in lines)
    matrix = np.ones((len(lines), max_len, 3), dtype=float)
    for i, line in enumerate(lines):
        for j, ch in enumerate(line):
            color = COLOR_MAP.get(ch, 'white')
            matrix[i, j] = mcolors.to_rgb(color)
    return matrix

def _legend_handles():
    # Jelmagyarázat elemei, a COLOR_MAP és magyarázat alapján
    labels = [
        ('.', 'új sor'),
        ('[', 'első ismétlődés'),
        ('*', 'folytatódó ismétlés'),
        ('?', '≥350 karakter egyezés'),
        ('!', '≥1250 karakter egyezés'),
    ]
    return [Patch(facecolor=COLOR_MAP[sym], edgecolor='none', label=f"{sym} = {desc}") for sym, desc in labels]

def plot_heatmap(matrix, out_path: Path, title: str, figw: float, figh: float, dpi: int):
    plt.figure(figsize=(figw, figh))
    if matrix.size == 0:
        plt.text(0.5, 0.5, "Nincs megjeleníthető adat", ha='center', va='center')
    else:
        plt.imshow(matrix, aspect='auto')
        ax = plt.gca()
        # Y tengely: egész számok, legalább 1-től
        ax.yaxis.set_major_locator(mticker.MaxNLocator(integer=True))
        ax.set_ylim(ax.get_ylim()[0], max(1, ax.get_ylim()[1]))
        # X tengely: egész számok
        ax.xaxis.set_major_locator(mticker.MaxNLocator(integer=True))
        ax.set_xlim(0, ax.get_xlim()[1])
        # Rácsvonalak (major grid)
        ax.grid(True, which='major', axis='both', linestyle=':', linewidth=0.5, alpha=0.6)
        ax.tick_params(axis='both', which='major', labelsize=8)
        # Jelmagyarázat
        handles = _legend_handles()
        leg = ax.legend(handles=handles, title="Jelmagyarázat", loc='upper center', bbox_to_anchor=(0.5, -0.12),
                        ncol=3, frameon=True, framealpha=0.95, fontsize=8, title_fontsize=9)
    plt.title(title, fontsize=16)
    plt.xlabel("Karakterek a sorban")
    plt.ylabel("Sorok (logból)")
    plt.tight_layout()
    plt.savefig(out_path, dpi=dpi, bbox_inches='tight')
    plt.close()

def marker_stats(lines):
    counts = {k: 0 for k in ['.', '[', '*', '?', '!']}
    for line in lines:
        for ch in line:
            if ch in counts:
                counts[ch] += 1
    total = sum(counts.values())
    return counts, total

def images_to_pdf_with_toc(image_paths, out_pdf: Path):
    if not _PDF_OK:
        raise RuntimeError("PDF funkcióhoz kell a Pillow és fpdf2: pip install pillow fpdf2")

    titles = [p.stem for p in image_paths]
    pdf = FPDF(unit="mm", format="A4")
    pdf.set_auto_page_break(auto=True, margin=15)

    # TOC
    pdf.add_page()
    pdf.set_font("Helvetica", "B", 18)
    pdf.cell(0, 12, "Tartalomjegyzék", ln=True, align="C")
    pdf.ln(5)
    pdf.set_font("Helvetica", size=12)
    for i, title in enumerate(titles):
        page_no = i + 2
        pdf.cell(0, 8, f"{title}  ........  {page_no}", ln=True)

    from PIL import Image
    for i, img_path in enumerate(image_paths):
        title = img_path.stem
        pdf.add_page()
        pdf.set_font("Helvetica", "B", 14)
        pdf.cell(0, 10, title, ln=True, align="C")
        try:
            pdf.bookmark(title, level=0)
        except Exception:
            pass
        pdf.ln(3)

        with Image.open(img_path) as img:
            w_px, h_px = img.size
        w_mm, h_mm = w_px * 0.264583, h_px * 0.264583
        page_w, page_h = 210, 297
        left_margin, right_margin, top_margin, bottom_margin = 10, 10, 25, 15
        max_w = page_w - left_margin - right_margin
        max_h = page_h - top_margin - bottom_margin
        scale = min(max_w / w_mm, max_h / h_mm, 1)
        w_mm *= scale
        h_mm *= scale
        x = (page_w - w_mm) / 2
        y = pdf.get_y()
        pdf.image(str(img_path), x=x, y=y, w=w_mm, h=h_mm)

    pdf.output(str(out_pdf), "F")

def main():
    parser = argparse.ArgumentParser(description="Per-fájl hőtérképek generálása logból, státusz prefix-szel (Rendben/Gyanús/Másolt).")
    parser.add_argument("--input", "-i", type=Path, required=True, help="Log file path")
    parser.add_argument("--outdir", "-o", type=Path, default=Path("."), help="Kimeneti mappa")
    parser.add_argument("--figw", type=float, default=18.0, help="Ábra szélessége (inch)")
    parser.add_argument("--figh", type=float, default=12.0, help="Ábra magassága (inch)")
    parser.add_argument("--dpi", type=int, default=300, help="Kimeneti DPI")
    parser.add_argument("--make-pdf", action="store_true", help="PNG-k összefűzése egy PDF-be a végén (TOC + cím ugyanazon az oldalon)")
    parser.add_argument("--pdf-name", type=str, default="heatmaps.pdf", help="PDF fájlnév (az --outdir-be kerül)")
    args = parser.parse_args()

    text = args.input.read_text(encoding="utf-8", errors="replace")
    blocks = extract_blocks(text)

    if not blocks:
        print("Nem találtam feldolgozható blokkot.")
        sys.exit(1)

    args.outdir.mkdir(parents=True, exist_ok=True)

    generated = []
    for original_name, safe_stem, lines, status in blocks:
        matrix = encode_matrix(lines)
        prefix = sanitize_filename(status) + "_" if status else ""
        out_path = args.outdir / f"{prefix}{safe_stem}.png"
        plot_heatmap(matrix, out_path, title=original_name, figw=args.figw, figh=args.figh, dpi=args.dpi)
        generated.append(out_path)

        counts, total = marker_stats(lines)
        def pct(n): return (n / total * 100) if total else 0.0
        print(f"[OK] {original_name} -> {out_path}  (sorok: {len(lines)}, szélesség: {matrix.shape[1]})")
        print("     Jelölés arányok:", ", ".join([f"{k}:{counts[k]} ({pct(counts[k]):.1f}%)" for k in ['.', '[', '*', '?', '!']]))

    if args.make_pdf:
        out_pdf = args.outdir / args.pdf_name
        images_to_pdf_with_toc(generated, out_pdf)
        print(f"[OK] PDF kész: {out_pdf} ({len(generated) + 1} oldal: 1 TOC + 1 oldal / kép)")

if __name__ == "__main__":
    main()
