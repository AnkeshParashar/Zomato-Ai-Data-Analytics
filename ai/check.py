from google import genai
import os
from dotenv import load_dotenv

load_dotenv()

# -----------------------------
# Model Name
# -----------------------------

client = genai.Client(
    api_key=os.getenv("GEMINI_API_KEY")
)
for model in client.models.list():
    print(model.name)

# -----------------------------
# Model Test
# -----------------------------

client = genai.Client(
    api_key=os.getenv("GEMINI_API_KEY")
)
response = client.models.generate_content(
    model="gemini-3.5-flash",
    contents="Say hello in one sentence."
)
print(response.text)
