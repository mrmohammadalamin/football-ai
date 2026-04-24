import os
from google_adk import Agent
from pydantic import BaseModel

# ---------------------------------------------------------
# Define the Output Schemas for structured Agent Responses
# ---------------------------------------------------------
class PlayEvent(BaseModel):
    timestamp: str
    description: str
    key_players: list[str]

class RefereeDecision(BaseModel):
    is_foul: bool
    is_offside: bool
    explanation: str

class Commentary(BaseModel):
    play_by_play: str
    excitement_level: int # 1 to 10

class MatchInsight(BaseModel):
    event: PlayEvent
    referee_decision: RefereeDecision
    commentary: Commentary

# ---------------------------------------------------------
# Define the Sub-Agents
# ---------------------------------------------------------

# 1. Vision Analyst Agent (The Eyes)
# Uses Gemini Flash for fast multimodal video/image processing.
vision_agent = Agent(
    name="VisionAnalyst",
    model="gemini-2.5-flash",
    instructions="""
    You are an expert football video analyst.
    Your job is to analyze the provided multimodal context (video, audio, or description).
    Extract the key physical events (passes, tackles, shots, runs) and identify the key players involved.
    Provide a detailed visual insight.
    """
)

# 2. Referee Agent (The Rules)
# Uses Gemini Pro for deeper reasoning about the rules of the game.
referee_agent = Agent(
    name="Referee",
    model="gemini-2.5-pro",
    instructions="""
    You are a professional football referee.
    Review the visual insights from the Vision Analyst.
    Determine if any rules were broken (fouls, offsides, handballs).
    Provide a clear explanation and your final decision.
    """
)

# 3. Commentary Agent (The Voice)
# Uses Gemini Flash to generate lively text suitable for TTS audio generation.
commentary_agent = Agent(
    name="Commentator",
    model="gemini-2.5-flash",
    instructions="""
    You are an energetic and famous football commentator.
    Based on the events and referee decisions, provide a thrilling play-by-play commentary.
    Your output will be fed directly into a Text-to-Speech (TTS) engine to generate live audio.
    Keep it short, punchy, and highly engaging. Include an excitement level (1-10).
    """
)

# 4. Fan Engagement Agent (The Crowd)
# Uses Gemini Pro to analyze fan sentiment and generate social media insights.
fan_engagement_agent = Agent(
    name="FanEngagement",
    model="gemini-2.5-pro",
    instructions="""
    You are a social media and fan engagement expert.
    Based on the current play, generate a "fan following insight". 
    Predict how the crowd and internet fans are reacting. Provide a trending hashtag and a short viral tweet describing the moment.
    """
)

# 5. Media Creator Agent (The Producer)
# Uses Gemini to generate prompts for downstream Video/Image Generation models (e.g. Imagen 3).
media_creator_agent = Agent(
    name="MediaCreator",
    model="gemini-2.5-pro",
    instructions="""
    You are a live broadcast visual effects producer.
    Based on the key event, generate a highly detailed prompt that can be sent to a Video Generation AI to create a dynamic visual effect, replay, or AR graphic overlay (e.g., "A glowing red trail following the football as it curves into the top corner").
    """
)

# ---------------------------------------------------------
# Define the Root Orchestrator Agent
# ---------------------------------------------------------
orchestrator_agent = Agent(
    name="FootballOrchestrator",
    model="gemini-2.5-pro",
    sub_agents=[vision_agent, referee_agent, commentary_agent, fan_engagement_agent, media_creator_agent],
    instructions="""
    You are the Football Match Insight Orchestrator.
    When you receive a video context or play description:
    1. Ask VisionAnalyst to describe the exact physical events.
    2. Pass findings to the Referee to check for rule violations.
    3. Pass events and decisions to the Commentator for the live script.
    4. Pass events to FanEngagement for crowd insights.
    5. Pass events to MediaCreator for a video generation prompt.
    6. Compile EVERYTHING into a comprehensive, structured JSON response.
    
    Ensure your final output is a clean JSON object ONLY containing exactly these keys:
    {
      "vision_analysis": "...",
      "referee_decision": "...",
      "commentary_text": "...",
      "excitement_level": 8,
      "fan_insight": "...",
      "video_generation_prompt": "..."
    }
    """
)

# Note: In a production Agent Engine deployment, you would expose this orchestrator.
# For local testing, we wrap it in FastAPI in main.py.
