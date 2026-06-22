"""
Escala todos los sprites PNG de una carpeta de 16x16 a 32x32
(factor 2x) usando interpolación NEAREST para conservar el aspecto
pixel-art sin modificaciones visuales.

Uso:
    python3 escalar_sprites.py                  → usa Cute_Fantasy_Free (por defecto)
    python3 escalar_sprites.py "ruta/a/carpeta" → usa la carpeta indicada
"""

import sys
from pathlib import Path
from PIL import Image

_BASE = Path(__file__).parent / "recursos" / "assetPack"
SOURCE_DIR = Path(sys.argv[1]) if len(sys.argv) > 1 else _BASE / "Cute_Fantasy_Free"
SCALE_FACTOR = 2


def escalar_imagen(ruta: Path) -> None:
    with Image.open(ruta) as img:
        nuevo_ancho = img.width * SCALE_FACTOR
        nuevo_alto  = img.height * SCALE_FACTOR
        img_escalada = img.resize((nuevo_ancho, nuevo_alto), Image.NEAREST)
        img_escalada.save(ruta)
    print(f"  ✓  {ruta.relative_to(SOURCE_DIR.parent.parent)}  "
          f"({img.width}×{img.height} → {nuevo_ancho}×{nuevo_alto})")


def main() -> None:
    pngs = sorted(SOURCE_DIR.rglob("*.png"))

    if not pngs:
        print("No se encontraron archivos PNG.")
        return

    print(f"Se encontraron {len(pngs)} archivos PNG en:\n  {SOURCE_DIR}\n")

    for ruta in pngs:
        try:
            escalar_imagen(ruta)
        except Exception as e:
            print(f"  ✗  Error en {ruta.name}: {e}")

    print(f"\nListo. {len(pngs)} imágenes escaladas ×{SCALE_FACTOR}.")


if __name__ == "__main__":
    main()
