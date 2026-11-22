"""產生 ATM Finder 的所有點陣圖示與 Play 商店素材（方案 B「出鈔口」）。

圖形與 app/lib/design/brand_mark.dart、Android adaptive icon 向量檔使用同一組
100×100 設計座標。用法（需要 Pillow）：

    python scripts/generate-brand-assets.py

輸出：
- app/assets/branding/atm-finder-icon-1024.png（母版）
- Android legacy mipmap（API 24–25；API 26+ 使用 mipmap-anydpi-v26 向量圖示）
- iOS AppIcon、Web icons／favicon
- release/store-assets/：Play 512 圖示、1024×500 主打圖片
"""

from __future__ import annotations

import json
import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent.parent
APP = ROOT / "app"

GREEN = (0x00, 0x6C, 0x4C)
MINT = (0x89, 0xF8, 0xC7)
WHITE = (0xFF, 0xFF, 0xFF)
SLOT_SHADOW = (0x00, 0x4D, 0x36, round(255 * 0.35))
FEATURE_MUTED = (0xCF, 0xF5, 0xE3)

SUPERSAMPLE = 4
ROUNDED_RADIUS = 22  # 設計座標，與 BrandMark 相同


def _cubic(
    p0: tuple[float, float],
    p1: tuple[float, float],
    p2: tuple[float, float],
    p3: tuple[float, float],
    steps: int = 48,
) -> list[tuple[float, float]]:
    points = []
    for index in range(1, steps + 1):
        t = index / steps
        u = 1 - t
        points.append(
            (
                u**3 * p0[0] + 3 * u**2 * t * p1[0] + 3 * u * t**2 * p2[0] + t**3 * p3[0],
                u**3 * p0[1] + 3 * u**2 * t * p1[1] + 3 * u * t**2 * p2[1] + t**3 * p3[1],
            )
        )
    return points


def _pin_polygon() -> list[tuple[float, float]]:
    start = (50.0, 66.5)
    points = [start]
    points += _cubic(start, (45.6, 61.6), (41.5, 57.8), (41.5, 52.6))
    # 半圓：從左 (41.5, 52.6) 經過頂端到右 (58.5, 52.6)
    for index in range(1, 65):
        angle = math.pi + math.pi * index / 64
        points.append((50 + 8.5 * math.cos(angle), 52.6 + 8.5 * math.sin(angle)))
    points += _cubic((58.5, 52.6), (58.5, 57.8), (54.4, 61.6), start)
    return points


def render_mark(size: int, *, rounded: bool) -> Image.Image:
    """Render the full-bleed icon. ``rounded`` gives transparent corners."""
    canvas = size * SUPERSAMPLE
    unit = canvas / 100

    def scaled(points: list[tuple[float, float]]) -> list[tuple[float, float]]:
        return [(x * unit, y * unit) for x, y in points]

    def box(x: float, y: float, w: float, h: float) -> list[float]:
        return [x * unit, y * unit, (x + w) * unit - 1, (y + h) * unit - 1]

    image = Image.new("RGBA", (canvas, canvas), GREEN + (255,))
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle(box(30, 35, 40, 38), radius=4.5 * unit, fill=MINT)
    draw.polygon(scaled(_pin_polygon()), fill=GREEN)
    draw.ellipse(box(50 - 3.2, 52.6 - 3.2, 6.4, 6.4), fill=MINT)

    shadow = Image.new("RGBA", image.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rectangle(box(30, 38.5, 40, 3), fill=SLOT_SHADOW)
    image = Image.alpha_composite(image, shadow)
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle(box(21, 29, 58, 10), radius=5 * unit, fill=WHITE)

    if rounded:
        mask = Image.new("L", image.size, 0)
        ImageDraw.Draw(mask).rounded_rectangle(
            [0, 0, canvas - 1, canvas - 1],
            radius=ROUNDED_RADIUS * unit,
            fill=255,
        )
        image.putalpha(mask)

    return image.resize((size, size), Image.Resampling.LANCZOS)


def _save_opaque(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.convert("RGB").save(path, optimize=True)


def _save_rgba(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, optimize=True)


def _font(names: list[str], size: int) -> ImageFont.FreeTypeFont:
    for name in names:
        for folder in (Path("C:/Windows/Fonts"), Path("/usr/share/fonts")):
            candidate = folder / name
            if candidate.exists():
                return ImageFont.truetype(str(candidate), size)
    sys.exit(f"找不到字型：{names}（主打圖片需要繁體中文字型）")


def render_feature_graphic() -> Image.Image:
    width, height = 1024, 500
    image = Image.new("RGB", (width, height), GREEN)
    icon = render_mark(220, rounded=True)
    image.paste(icon, (80, (height - 220) // 2), icon)

    bold = ["msjhbd.ttc"]
    regular = ["msjh.ttc"]
    draw = ImageDraw.Draw(image)
    x = 80 + 220 + 56
    draw.text((x, 168), "台灣 ATM Finder", font=_font(bold, 60), fill=WHITE)
    draw.text((x, 250), "離線也能找附近的 ATM", font=_font(regular, 30), fill=WHITE)
    draw.text(
        (x, 310),
        "全台 2.7 萬個 ATM 據點・不用登入・沒有廣告",
        font=_font(regular, 20),
        fill=FEATURE_MUTED,
    )
    return image


def main() -> None:
    _save_opaque(
        render_mark(1024, rounded=False),
        APP / "assets/branding/atm-finder-icon-1024.png",
    )

    mipmaps = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
    for density, size in mipmaps.items():
        _save_rgba(
            render_mark(size, rounded=True),
            APP / f"android/app/src/main/res/mipmap-{density}/ic_launcher.png",
        )

    # iOS 圖示不可有透明，由系統自行套圓角。
    icon_set = APP / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
    contents = json.loads((icon_set / "Contents.json").read_text(encoding="utf-8"))
    for entry in contents["images"]:
        points = float(entry["size"].split("x")[0])
        scale = int(entry["scale"].rstrip("x"))
        _save_opaque(
            render_mark(round(points * scale), rounded=False),
            icon_set / entry["filename"],
        )

    web = APP / "web"
    _save_opaque(render_mark(32, rounded=False), web / "favicon.png")
    for size in (192, 512):
        _save_opaque(render_mark(size, rounded=False), web / f"icons/Icon-{size}.png")
        _save_opaque(
            render_mark(size, rounded=False),
            web / f"icons/Icon-maskable-{size}.png",
        )

    store = ROOT / "release/store-assets"
    _save_opaque(render_mark(512, rounded=False), store / "play-icon-512.png")
    _save_opaque(render_feature_graphic(), store / "feature-graphic-1024x500.png")
    print("已產生品牌圖示與商店素材。")


if __name__ == "__main__":
    main()
