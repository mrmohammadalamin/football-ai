import os
import json
import base64
import io
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv
import vertexai
from gtts import gTTS
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

from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Football AI Agent API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class VideoContextRequest(BaseModel):
    video_description: str 
    custom_query: str = None

class InsightResponse(BaseModel):
    vision_analysis: str
    referee_decision: str
    commentary_text: str
    excitement_level: int
    fan_insight: str
    video_generation_prompt: str
    audio_base64: str

def generate_tts(text: str) -> str:
    """Generates base64 encoded audio from text using gTTS."""
    try:
        tts = gTTS(text, lang='en')
        fp = io.BytesIO()
        tts.write_to_fp(fp)
        fp.seek(0)
        return base64.b64encode(fp.read()).decode("utf-8")
    except Exception as e:
        print(f"TTS generation failed: {e}")
        # Return empty base64 string on failure
        return ""

@app.post("/analyze", response_model=InsightResponse)
async def analyze_video(request: VideoContextRequest):
    """
    Endpoint to receive video context and pass it to the ADK Orchestrator.
    """
    try:
        prompt = f"Analyze the following video segment: {request.video_description}"
        if request.custom_query:
            prompt += f"\nUser Custom Question: {request.custom_query}"
        
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
        
        # Save to AlloyDB
        if db_pool:
            try:
                with db_pool.connect() as conn:
                    # Create table if it doesn't exist
                    conn.execute(sqlalchemy.text("""
                        CREATE TABLE IF NOT EXISTS insights (
                            id SERIAL PRIMARY KEY,
                            vision_analysis TEXT,
                            referee_decision TEXT,
                            commentary_text TEXT,
                            excitement_level INTEGER,
                            fan_insight TEXT,
                            video_generation_prompt TEXT
                        )
                    """))
                    conn.commit()
                    
                    # Insert the new insight
                    conn.execute(sqlalchemy.text("""
                        INSERT INTO insights (vision_analysis, referee_decision, commentary_text, excitement_level, fan_insight, video_generation_prompt)
                        VALUES (:vision, :referee, :commentary, :excitement, :fan, :prompt)
                    """), {
                        "vision": data.get("vision_analysis", ""),
                        "referee": data.get("referee_decision", ""),
                        "commentary": data.get("commentary_text", ""),
                        "excitement": data.get("excitement_level", 5),
                        "fan": data.get("fan_insight", ""),
                        "prompt": data.get("video_generation_prompt", "")
                    })
                    conn.commit()
            except Exception as e:
                print(f"Failed to write to AlloyDB: {e}")
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
    port = int(os.environ.get("PORT", 8080))
    uvicorn.run(app, host="0.0.0.0", port=port)
