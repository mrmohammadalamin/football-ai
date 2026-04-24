import os
import json
import base64
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv
import vertexai
from google.cloud import texttospeech
import sqlalchemy

# Load environment variables
load_dotenv()

# Initialize Vertex AI
PROJECT_ID = os.environ.get("GOOGLE_CLOUD_PROJECT", "your-project-id")
LOCATION = os.environ.get("GOOGLE_CLOUD_LOCATION", "us-central1")
try:
    vertexai.init(project=PROJECT_ID, location=LOCATION)
except Exception as e:
    print(f"Warning: Vertex AI initialization failed. Please set GOOGLE_CLOUD_PROJECT. Error: {e}")

# Initialize AlloyDB Connection Pool (Stub for GCP Configuration)
def init_connection_pool():
    # Use environment variables to configure AlloyDB/PostgreSQL connection
    db_user = os.environ.get("DB_USER", "postgres")
    db_pass = os.environ.get("DB_PASS", "password")
    db_name = os.environ.get("DB_NAME", "football_db")
    db_host = os.environ.get("DB_HOST", "127.0.0.1")
    
    # Example using pg8000
    try:
        pool = sqlalchemy.create_engine(
            f"postgresql+pg8000://{db_user}:{db_pass}@{db_host}/{db_name}",
        )
        return pool
    except Exception as e:
        print(f"Database connection skipped or failed: {e}")
        return None

db_pool = init_connection_pool()

from agent import orchestrator_agent

app = FastAPI(title="Football AI Agent API")

class VideoContextRequest(BaseModel):
    video_description: str 

class InsightResponse(BaseModel):
    vision_analysis: str
    referee_decision: str
    commentary_text: str
    excitement_level: int
    fan_insight: str
    video_generation_prompt: str
    audio_base64: str

def generate_tts(text: str) -> str:
    """Generates base64 encoded audio from text using Google Cloud TTS."""
    try:
        client = texttospeech.TextToSpeechClient()
        synthesis_input = texttospeech.SynthesisInput(text=text)
        voice = texttospeech.VoiceSelectionParams(
            language_code="en-US",
            name="en-US-Journey-D", # A nice dynamic voice
        )
        audio_config = texttospeech.AudioConfig(
            audio_encoding=texttospeech.AudioEncoding.MP3
        )
        response = client.synthesize_speech(
            input=synthesis_input, voice=voice, audio_config=audio_config
        )
        return base64.b64encode(response.audio_content).decode("utf-8")
    except Exception as e:
        print(f"TTS generation failed: {e}")
        # Return empty base64 string on failure (e.g. missing credentials)
        return ""

@app.post("/analyze", response_model=InsightResponse)
async def analyze_video(request: VideoContextRequest):
    """
    Endpoint to receive video context and pass it to the ADK Orchestrator.
    """
    try:
        prompt = f"Analyze the following video segment: {request.video_description}"
        
        # Invoke the Orchestrator
        response_text = orchestrator_agent.invoke(prompt)
        
        # Parse the JSON response
        try:
            # Strip markdown formatting if any
            clean_text = response_text.strip()
            if clean_text.startswith("```json"):
                clean_text = clean_text[7:-3]
            elif clean_text.startswith("```"):
                clean_text = clean_text[3:-3]
                
            data = json.loads(clean_text)
        except json.JSONDecodeError:
            # Fallback if agent doesn't return pure JSON
            data = {
                "vision_analysis": "Error parsing vision data.",
                "referee_decision": "Error parsing referee data.",
                "commentary_text": response_text,
                "excitement_level": 5,
                "fan_insight": "Error parsing fan insight.",
                "video_generation_prompt": "Error parsing media prompt."
            }
            
        # Generate Audio from Commentary
        audio_b64 = generate_tts(data.get("commentary_text", ""))
        
        # Optionally, save to AlloyDB here
        # if db_pool:
        #     with db_pool.connect() as conn:
        #         # Insert into insights table
        #         pass

        return InsightResponse(
            vision_analysis=data.get("vision_analysis", ""),
            referee_decision=data.get("referee_decision", ""),
            commentary_text=data.get("commentary_text", ""),
            excitement_level=data.get("excitement_level", 5),
            fan_insight=data.get("fan_insight", ""),
            video_generation_prompt=data.get("video_generation_prompt", ""),
            audio_base64=audio_b64
        )
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
