# Workshop Presentation Script: Building Production-Ready "Football AI"

**Target Audience:** Hackathon participants (developers, data scientists)
**Goal:** Mentor the students on how to choose the right Google Cloud AI architecture (Agent Engine, AlloyDB, ADK) and how to handle real-world scenarios like live video analysis, preparing them to build their own agentic apps.

---

## Slide 1: Title & Welcome
*   **Visual:** "'U' Hack! Code in Black & White" logo + Session Title: "Building production ready Football AI: ADK, Agent Engine & Intelligent Database".
*   **Script:** "Welcome everyone! Today, we're going to talk about the technology behind modern sports apps. On-field performance increasingly starts behind screens. We're moving from just looking at data to having AI agents actively analyze and make decisions based on real-time game flow."

## Slide 2: The Shift to Agentic AI
*   **Visual:** Diagram comparing a single LLM chat interface vs. a multi-agent system (orchestrator routing to specialized agents).
*   **Script:** "You've all used ChatGPT or Gemini. But when building a production app, you don't just want a chatbot. You want an 'Agentic System'—where different autonomous programs (agents) talk to models to achieve specific goals, using specific tools. For football AI, you might need one agent to watch the video, another to check historical stats, and another to formulate a strategy."

## Slide 3: The Google Cloud AI Stack for Sports
*   **Visual:** Three pillars: Vertex AI Agent Development Kit (ADK), Agent Engine, and AlloyDB for PostgreSQL.
*   **Script:** "Choosing the right foundation is critical.
    *   **ADK (Agent Development Kit):** Your framework for building and connecting these agents. It's modular and flexible.
    *   **Agent Engine:** Where your agents live. It's a serverless runtime that handles the scaling and orchestration.
    *   **AlloyDB:** Your intelligent database. It's not just for storing player names; it handles vector embeddings, allowing your agents to search for similar historical plays in milliseconds."

## Slide 4: The Demonstration Scenario
*   **Visual:** A diagram showing a video feed -> Video Analyst Agent -> Tactical Coach Agent <- Database Agent (connected to AlloyDB).
*   **Script:** "Let's look at a concrete example. We want to build an AI that acts as an assistant coach. It needs to see what's happening on the pitch right now, cross-reference that with the opponent's historical data, and suggest a tactical change. We will use three distinct agents to do this."

## Slide 5: Handling Video (The Live Stream Concept)
*   **Visual:** Code snippet showing Gemini Multimodal input, alongside a graphic of a camera feeding into a server.
*   **Script:** "The most challenging part of sports AI is the video. Now, for our demo today, I'm going to show you this working with a *pre-recorded video* for simplicity.
    *   **How it works in the real world:** You would connect an RTSP stream (a live camera feed) to a backend service. This service captures frames (say, 1 frame per second) or short video chunks and passes them directly to **Gemini Flash**.
    *   Gemini Flash's multimodal capabilities mean we don't need a complex pipeline of object detection models just to understand the game state. We can ask Gemini: 'What formation is the team in white currently playing based on this video?' and get a near-instant answer."

## Slide 6: The Intelligent Database (AlloyDB)
*   **Visual:** SQL query snippet showing a pgvector similarity search, or a diagram of an agent querying AlloyDB.
*   **Script:** "While the video tells us *what* is happening, the database tells us *who* and *why*. Your agents need grounding. We use AlloyDB because it combines the reliability of PostgreSQL with enterprise AI capabilities. Our 'Database Agent' uses a tool (a Cloud Run function) to query AlloyDB. If the Video Agent spots player #10 making a run, the DB Agent checks AlloyDB to see if player #10 usually crosses or shoots from that position."

## Slide 7: Putting it together with ADK (Live Demo / Walkthrough)
*   **Visual:** Terminal showing `adk run .` or the ADK web interface.
*   **Script:** "Let's look at the code. *(Switch to code editor / live demo of the ADK app running the pre-recorded video)*. Here we have our root agent, the Tactical Coach. I'm going to ask it for advice based on the video we just fed it. Notice how it delegates the visual task to the Video Analyst, and the data lookup to the DB Agent."

## Slide 8: Deployment & Scale
*   **Visual:** Terminal showing `adk deploy agent_engine`.
*   **Script:** "You've built your prototype locally. How do you scale it for the hackathon judging or for thousands of users? Agent Engine. With one command, your local multi-agent system becomes a highly available API endpoint on Google Cloud, ready to be integrated into your frontend web or mobile apps."

## Slide 9: Your Turn!
*   **Visual:** Link to the Hackathon resources/repo and a call to action.
*   **Script:** "Whether you are building for player performance, tactical analysis, or fan engagement, you now have the blueprint. Think about how *you* can use these tools—ADK, Agent Engine, AlloyDB, and Gemini's video capabilities—for your hackathon projects. The lab guide will walk you through setting up a baseline architecture you can customize. Good luck!"
