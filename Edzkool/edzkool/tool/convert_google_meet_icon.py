from PIL import Image
import os

src = r"x:\edvoyage-backup-cursor\Edzkool\edzkool\assets\google-meet--v2.jpg"
out = r"x:\edvoyage-backup-cursor\Edzkool\edzkool\assets\google_meet.png"

img = Image.open(src).convert("RGBA")
w, h = img.size
side = min(w, h)
left = (w - side) // 2
top = (h - side) // 2
img = img.crop((left, top, left + side, top + side))

pixels = img.load()
for y in range(img.height):
    for x in range(img.width):
        r, g, b, a = pixels[x, y]
        if r > 240 and g > 240 and b > 240:
            pixels[x, y] = (r, g, b, 0)

img = img.resize((48, 48), Image.Resampling.LANCZOS)

silhouette = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
sp = silhouette.load()
ip = img.load()
for y in range(48):
    for x in range(48):
        r, g, b, a = ip[x, y]
        if a > 30:
            sp[x, y] = (255, 255, 255, min(255, a))

silhouette.save(out, optimize=True)
print(f"Saved {out} ({os.path.getsize(out)} bytes)")
