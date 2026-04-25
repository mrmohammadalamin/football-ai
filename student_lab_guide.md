# Student Lab Guide: Building a Football AI Multi-Agent System

Welcome to the lab! In this session, you'll learn how to set up a multi-agent system using Google Cloud, grounded in an AlloyDB database, and capable of multimodal video analysis.

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

## Step 1: Database Setup (AlloyDB)

We need a place to store our live agent insights and historical match data.

1.  Navigate to **AlloyDB** in the Google Cloud Console.
2.  Click **CREATE CLUSTER**.
    *   Cluster ID: `football-data-cluster`
    *   Password: `<your-password>`
    *   Region: `us-central1` (or your preferred region)
3.  Once the cluster and primary instance are created, open **AlloyDB Studio**.
4.  Create the table that our agents will write insights to:

```sql
CREATE TABLE IF NOT EXISTS insights (
    id SERIAL PRIMARY KEY,
    vision_analysis TEXT,
    referee_decision TEXT,
    commentary_text TEXT,
    excitement_level INTEGER,
    fan_insight TEXT,
    video_generation_prompt TEXT
);
```

## Step 2: Environment Setup

Create your project folder and virtual environment:
```bash
mkdir football-ai-agent
cd football-ai-agent
python -m venv .venv
source .venv/bin/activate
pip install fastapi uvicorn pydantic google-genai sqlalchemy pg8000 gTTS
```

## Step 3: Writing the Multi-Agent System (`agent.py`)

Here is a blueprint of how you structure a multi-agent system for sports analysis. Save this as `agent.py`.

```python
from google_adk import Agent, Tool

# Define specific sub-agents
vision_analyst = Agent(
    name="VisionAnalyst",
    model="gemini-2.5-flash",
    instructions="Analyze the video/image to describe tactical setup, player formations, and threats."
)

referee_agent = Agent(
    name="RefereeAgent",
    model="gemini-2.5-flash",
    instructions="Act as a virtual referee. Look for offsides, fouls, or handball violations."
)

# Root Orchestrator
orchestrator_agent = Agent(
    name="MatchOrchestrator",
    model="gemini-2.5-pro",
    sub_agents=[vision_analyst, referee_agent],
    instructions="""
    Coordinate the analysis of the football match. 
    1. Ask Vision Analyst for the play breakdown.
    2. Ask Referee Agent for rule checks.
    3. Return a JSON payload containing: vision_analysis, referee_decision, commentary_text, excitement_level.
    """
)
```

## Step 4: Deployment Options

Depending on the availability of Vertex AI features and your specific application needs, you have two options for deploying your agent backend.

### Option A: Vertex AI Agent Engine (Recommended for Managed ADK)
If the Google Cloud Agent Engine is active in your project, this is the easiest way to deploy standard ADK scripts.

```bash
adk deploy agent_engine \
  --project $GOOGLE_CLOUD_PROJECT \
  --region us-central1 \
  --staging_bucket gs://<YOUR_BUCKET_NAME> \
  .
```
This provides a managed REST endpoint for your frontend.

### Option B: Custom FastAPI on Cloud Run (Recommended for Custom UIs & Audio)
If you are building a custom Flutter or React frontend that requires complex CORS configurations, custom audio streaming, or direct AlloyDB connections, we recommend wrapping the agent in FastAPI.

1. **Create `main.py`**: Write a FastAPI wrapper around your `orchestrator_agent.invoke()`.
2. **Deploy to Cloud Run**: Use the following command to deploy the container securely, ensuring it can talk to your private AlloyDB instance.

```bash
gcloud run deploy football-ai-backend \
  --source . \
  --region us-central1 \
  --allow-unauthenticated \
  --vpc-egress=private-ranges-only \
  --network=default \
  --set-env-vars="DB_USER=postgres,DB_PASS=yourpassword,DB_NAME=postgres,DB_HOST=10.61.0.2"
```

> [!TIP]
> **VPC Egress is Critical!** The `--vpc-egress=private-ranges-only` flag ensures your Cloud Run service can access your private AlloyDB database *without* blocking its ability to reach out to the public internet (for things like Google APIs).

## Step 5: Connecting the Frontend (Flutter Web)

Once your backend is deployed (via Option A or Option B), you can connect your frontend UI. 

In Flutter, you can use a background `Timer` to create a continuous "Live Broadcast" feel:

```dart
// In main.dart
void _startPolling() {
  Timer.periodic(const Duration(seconds: 7), (timer) {
    _analyzeCurrentPlay(); // Calls your Cloud Run or Agent Engine URL!
  });
}
```

Use the `flutter_tts` package to instantly read the `commentary_text` out loud to the user as the data flows in!
