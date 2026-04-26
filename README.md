# Football Match Analysis AI Prototype

This repository contains the code for a full-stack, multi-agent Agentic application built on Google Cloud. It uses Google ADK and Gemini to analyze football videos, detect rules, and generate live commentary, presented through a Flutter UI.

## Architecture
1.  **Backend (Python + ADK + FastAPI)**: A 4-agent system running on a local server (ready for Agent Engine deployment).
    *   **Vision Analyst Agent**: Extracts physical events from video context.
    *   **Referee Agent**: Determines if fouls occurred.
    *   **Commentary Agent**: Generates play-by-play.
    *   **Root Orchestrator**: Coordinates the flow.
2.  **Frontend (Flutter)**: A clean desktop/web UI to upload a video, play it, and request live insights.

---

## 1. How to Run the Backend

You must have Python 3.9+ installed and a Google Cloud Project with the Vertex AI API enabled.

```bash
cd backend

# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows use: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set your Google Cloud Project ID
export GOOGLE_CLOUD_PROJECT="your-project-id"

# Run the FastAPI server
python main.py
```
The server will start on `http://localhost:8000`.

---

## 2. How to Run the Frontend

You must have Flutter installed on your machine.

```bash
cd frontend

# Get dependencies
flutter pub get

# Run the app (Desktop or Chrome is recommended for testing)
flutter run -d chrome
# OR
flutter run -d windows
```

### Usage
1.  Click the Upload icon in the top right to select a local video file.
2.  Play the video.
3.  Click "Analyze Live Action" to send the current video context to the ADK backend.
4.  The right panel will populate with the Multi-Agent insights!

### Video Demo

Here is a video demo of the application:

[![Football AI Demo](https://img.youtube.com/vi/Rrli5nphch4/0.jpg)](https://www.youtube.com/watch?v=Rrli5nphch4)

[![Football AI Demo-2](https://img.youtube.com/vi/_Tsu66yyfNc/0.jpg)](https://www.youtube.com/watch?v=_Tsu66yyfNc)

