# Student Lab Guide: Building a Football AI Multi-Agent System

Welcome to the lab! In this session, you'll learn how to set up a multi-agent system using Google Cloud's Agent Development Kit (ADK), grounded in an AlloyDB database, and capable of multimodal video analysis.

This template is a starting point for your hackathon project. You can customize the agents, the database schema, and the tools to fit your specific idea.

## Prerequisites

1.  A Google Cloud Project with billing enabled.
2.  Python 3.9+ installed.
3.  Google Cloud CLI (`gcloud`) installed and authenticated.

Enable required APIs in Cloud Shell:
```bash
gcloud services enable artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    run.googleapis.com \
    aiplatform.googleapis.com \
    alloydb.googleapis.com
```

## Step 1: ADK Environment Setup

Create your project folder and virtual environment:
```bash
mkdir football-ai-agent
cd football-ai-agent
python -m venv .venv
source .venv/bin/activate
pip install google-adk vertexai google-cloud-storage
```

Create the project structure:
```bash
touch __init__.py agent.py .env requirements.txt
```

## Step 2: Database Setup (AlloyDB)

We need a place to store player stats and historical match data.

1.  Navigate to **AlloyDB** in the Google Cloud Console.
2.  Click **CREATE CLUSTER**.
    *   Cluster ID: `football-data-cluster`
    *   Password: `<your-password>`
    *   Region: `us-central1` (or your preferred region)
3.  Once the cluster and primary instance are created, open **AlloyDB Studio**.
4.  Create a sample table for player statistics:

```sql
CREATE TABLE player_stats (
    player_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    team VARCHAR(100) NOT NULL,
    position VARCHAR(50),
    stamina_level INT,
    preferred_foot VARCHAR(10),
    historical_conversion_rate DECIMAL(5,2)
);

INSERT INTO player_stats (player_id, name, team, position, stamina_level, preferred_foot, historical_conversion_rate)
VALUES ('p01', 'Striker A', 'Home Team', 'Forward', 85, 'Right', 22.5);
```

> [!TIP]
> **For the Hackathon:** You will likely want to build a Cloud Run function (similar to the kitchen renovation tutorial) that acts as a secure API between your ADK agents and your AlloyDB instance.

## Step 3: Writing the Multi-Agent System (`agent.py`)

Here is a simplified blueprint of how you structure a multi-agent system in ADK for sports analysis.

```python
import os
from google_adk import Agent, Tool
import vertexai
from vertexai.generative_models import GenerativeModel, Part

# --- Configuration ---
# Ensure your .env file is loaded or variables are exported
PROJECT_ID = os.environ.get("GOOGLE_CLOUD_PROJECT")
vertexai.init(project=PROJECT_ID, location="us-central1")

# --- Tools ---
@Tool
def get_player_stats(player_name: str) -> str:
    """
    Connects to AlloyDB (via a Cloud Run endpoint or directly) to fetch player stats.
    For this lab template, we return mocked data. In production, make the DB call here.
    """
    # Example mock response
    if "Striker A" in player_name:
        return '{"name": "Striker A", "stamina": 85, "conversion_rate": 22.5}'
    return "Player not found."

# --- Sub-Agents ---

# 1. The Video Analyst Agent
video_analyst_agent = Agent(
    name="VideoAnalystAgent",
    model="gemini-2.5-flash", # Use Flash for fast video/image processing
    instructions="""
    You are an expert football video analyst. When provided with a video or an image,
    describe the tactical setup, player formations, and any immediate threats.
    Be concise and focus on spatial data.
    """
)

# 2. The Database Agent
stats_agent = Agent(
    name="StatsAgent",
    model="gemini-2.5-pro",
    tools=[get_player_stats],
    instructions="""
    You are a sports data scientist. Use the get_player_stats tool to retrieve
    information about players from our AlloyDB database when asked.
    """
)

# --- Root Orchestrator Agent ---

root_agent = Agent(
    name="TacticalCoachAgent",
    model="gemini-2.5-pro",
    sub_agents=[video_analyst_agent, stats_agent],
    instructions="""
    You are the Head Tactical Coach. You coordinate with your VideoAnalystAgent and StatsAgent.
    When asked for tactical advice:
    1. Ask the VideoAnalystAgent to describe the current situation on the pitch.
    2. Identify key players mentioned.
    3. Ask the StatsAgent for data on those specific players.
    4. Provide a final strategic recommendation based on BOTH the visual situation and the data.
    """
)
```

## Step 4: Running the Agent

1. Create a `.env` file and add your `GOOGLE_CLOUD_PROJECT` ID.
2. Run the agent locally:

```bash
adk run .
```

*Test Prompt:* "Analyze the current video feed (assume I just uploaded a clip of Striker A making a run) and tell me if our defenders should step up based on his stats."

## Step 5: Scaling with Agent Engine

Once your local ADK app is perfect, you need to deploy it so your frontend (React, Flutter, etc.) can talk to it.

```bash
adk deploy agent_engine \
  --project $GOOGLE_CLOUD_PROJECT \
  --region us-central1 \
  --staging_bucket gs://<YOUR_BUCKET_NAME> \
  .
```

This will give you a REST endpoint you can call securely from your applications!

## Moving to Real-Time (Concept)
For a real hackathon product, you wouldn't just upload pre-recorded videos. You would:
1. Capture frames from an RTSP camera stream or live broadcast using a backend service (e.g., Python OpenCV).
2. Upload chunks to Cloud Storage or pass base64 encoded frames directly into the Gemini API.
3. Trigger your ADK agent continuously or on-demand based on those live frames.
