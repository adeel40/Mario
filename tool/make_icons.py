from PIL import Image, ImageDraw, ImageFont
import os

BASE = "/projects/sandbox/super_dash/android/app/src/main/res"

sizes = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

RED = (229, 37, 33, 255)
SKY = (92, 148, 252, 255)
WHITE = (255, 255, 255, 255)


def load_font(px):
    candidates = [
        "/usr/share/fonts/dejavu-sans-fonts/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf",
        "DejaVuSans-Bold.ttf",
    ]
    for c in candidates:
        try:
            return ImageFont.truetype(c, int(px * 0.5))
        except Exception:
            continue
    return ImageFont.load_default()


def make_icon(px):
    img = Image.new("RGBA", (px, px), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    r = int(px * 0.22)
    d.rounded_rectangle([0, 0, px - 1, px - 1], radius=r, fill=SKY)
    d.rounded_rectangle(
        [int(px * 0.12), int(px * 0.14), int(px * 0.88), int(px * 0.5)],
        radius=int(px * 0.08), fill=RED)
    font = load_font(px)
    text = "S"
    bbox = d.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    d.text(((px - tw) / 2 - bbox[0], int(px * 0.42) - bbox[1]), text,
           font=font, fill=WHITE)
    return img


for folder, px in sizes.items():
    path = os.path.join(BASE, folder)
    os.makedirs(path, exist_ok=True)
    make_icon(px).save(os.path.join(path, "ic_launcher.png"))
    print("wrote", os.path.join(folder, "ic_launcher.png"), f"{px}x{px}")

print("done")
