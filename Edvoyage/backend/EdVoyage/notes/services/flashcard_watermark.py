"""Apply EdVoyage diagonal watermark grid (same logic as vector/main.py)."""

from __future__ import annotations

import os
from functools import lru_cache
from pathlib import Path

from PIL import Image

LOGO_PATH = Path(__file__).resolve().parent.parent / "assets" / "watermark_logo.png"

LOGO_OPACITY = float(os.getenv("FLASHCARD_WATERMARK_OPACITY", "0.4"))
CROP_PERCENT = float(os.getenv("FLASHCARD_WATERMARK_CROP_PERCENT", "0.05"))
LOGO_WIDTH_RATIO = float(os.getenv("FLASHCARD_WATERMARK_WIDTH_RATIO", "0.15"))
LOGO_ROTATE_DEGREES = int(os.getenv("FLASHCARD_WATERMARK_ROTATE", "30"))
WATERMARK_ROWS = int(os.getenv("FLASHCARD_WATERMARK_ROWS", "4"))
LOGOS_PER_ROW = int(os.getenv("FLASHCARD_WATERMARK_LOGOS_PER_ROW", "2"))
DIAGONAL_SHIFT_RATIO = float(os.getenv("FLASHCARD_WATERMARK_DIAGONAL_RATIO", "0.35"))


def _crop_edges(image: Image.Image, percent: float) -> Image.Image:
    """Crop `percent` from top, bottom, left, and right."""
    if percent <= 0:
        return image
    w, h = image.size
    left = int(w * percent)
    top = int(h * percent)
    right = w - left
    bottom = h - top
    return image.crop((left, top, right, bottom))


def _with_opacity(image: Image.Image, opacity: float) -> Image.Image:
    """Make dark background fully transparent, then scale logo alpha."""
    image = image.copy()
    pixels = image.load()
    for y in range(image.height):
        for x in range(image.width):
            r, g, b, a = pixels[x, y]
            if r < 40 and g < 40 and b < 40:
                pixels[x, y] = (0, 0, 0, 0)
            else:
                pixels[x, y] = (r, g, b, int(a * opacity))
    return image


@lru_cache(maxsize=8)
def _prepare_logo_stamp(logo_width: int) -> Image.Image:
    logo = Image.open(LOGO_PATH).convert("RGBA")
    aspect = logo.height / logo.width
    logo = logo.resize((logo_width, int(logo_width * aspect)))
    logo = logo.rotate(LOGO_ROTATE_DEGREES, expand=True)
    return _with_opacity(logo, LOGO_OPACITY)


def apply_watermark(base: Image.Image) -> Image.Image:
    """Crop page edges, then overlay the EdVoyage logo grid before JPEG storage."""
    base = _crop_edges(base, CROP_PERCENT)

    if not LOGO_PATH.exists():
        return base

    base = base.convert("RGBA")
    logo_width = int(base.width * LOGO_WIDTH_RATIO)
    logo = _prepare_logo_stamp(logo_width)

    overlay = Image.new("RGBA", base.size, (0, 0, 0, 0))

    diagonal_shift = int(logo.width * DIAGONAL_SHIFT_RATIO)
    x_positions = [
        int((i + 1) * base.width / (LOGOS_PER_ROW + 1)) - logo.width // 2
        for i in range(LOGOS_PER_ROW)
    ]

    for row in range(WATERMARK_ROWS):
        y = int((row + 1) * base.height / (WATERMARK_ROWS + 1))

        for x in x_positions:
            x_shifted = x + row * diagonal_shift

            if (
                x_shifted + logo.width > 0
                and x_shifted < base.width
                and y + logo.height > 0
                and y < base.height
            ):
                overlay.paste(logo, (int(x_shifted), int(y)), logo)

    return Image.alpha_composite(base, overlay)
