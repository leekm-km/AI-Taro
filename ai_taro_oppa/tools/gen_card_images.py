import os, base64
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv(os.path.join(os.path.dirname(__file__), "..", "backend", ".env"))
client = OpenAI()

SAVE_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "cards")
os.makedirs(SAVE_DIR, exist_ok=True)

cards = [
    {"id": "major_00_fool", "prompt": "Tarot card of The Fool, youth at a cliff edge, knapsack on staff, white rose, little dog, bright sun, clean ornate border, full color, sharp line art"},
    {"id": "major_01_magician", "prompt": "Tarot card of The Magician, wand cup sword pentacle on table, infinity symbol above head, one hand up one down, clean ornate border, full color, sharp line art"}
]

model = os.getenv("IMAGE_MODEL", "gpt-image-1")

for card in cards:
   result = client.images.generate(
    model=model,
    prompt=card["prompt"],
    size="1024x1536"
)
   img = base64.b64decode(result.data[0].b64_json)
   out = os.path.join(SAVE_DIR, f"{card['id']}.png")
   with open(out, "wb") as f:
       f.write(img)
   print(out)
