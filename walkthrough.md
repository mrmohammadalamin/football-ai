# Football AI Workshop Materials Walkthrough

This walkthrough summarizes the workshop materials designed for the "'U' Hack! Code in Black & White" hackathon mentor.

## Goal Accomplished
Created a comprehensive set of resources to empower a mentor to teach students how to build production-ready, multi-agent AI systems for sports analysis using Google Cloud (ADK, Agent Engine, and AlloyDB). The materials are tailored to demonstrate the transition from pre-recorded conceptual demos to real-world live stream integration.

## Materials Created

1.  **[Workshop Presentation Script](file:///C:/Users/mrmoh/.gemini/antigravity/brain/a91186b3-fb3b-41dc-a3ab-a9e3e946b45b/workshop_presentation.md)**
    *   **Purpose:** A slide-by-slide script for the mentor to introduce the concepts of Agentic AI, Google Cloud's AI stack, and the specific Football AI architecture.
    *   **Highlights:** Explains the conceptual shift from chatbots to autonomous agents. Clearly addresses how to handle live video conceptually (RTSP streams -> frame extraction -> Gemini Flash) while acknowledging the use of a pre-recorded video for the live demo to ensure reliability.

2.  **[Student Lab Guide](file:///C:/Users/mrmoh/.gemini/antigravity/brain/a91186b3-fb3b-41dc-a3ab-a9e3e946b45b/student_lab_guide.md)**
    *   **Purpose:** A technical blueprint for students to use as a starting point for their hackathon projects.
    *   **Highlights:** Provides concrete setup commands for ADK, SQL schemas for AlloyDB, and a robust `agent.py` template demonstrating a 3-agent setup (Video Analyst, Database Stats Agent, and Tactical Root Agent). It concludes with commands on how to deploy this to Agent Engine.

3.  **[Implementation Plan](file:///C:/Users/mrmoh/.gemini/antigravity/brain/a91186b3-fb3b-41dc-a3ab-a9e3e946b45b/implementation_plan.md)**
    *   **Purpose:** The initial architectural design document, updated to reflect the mentoring context.

## How to Use These Materials

*   **During the Presentation:** Use the [Workshop Presentation Script](file:///C:/Users/mrmoh/.gemini/antigravity/brain/a91186b3-fb3b-41dc-a3ab-a9e3e946b45b/workshop_presentation.md) to guide your slides. Emphasize *why* these specific tools (Gemini Flash for speed, AlloyDB for grounding) were chosen.
*   **During the Lab/Mentoring:** Distribute the [Student Lab Guide](file:///C:/Users/mrmoh/.gemini/antigravity/brain/a91186b3-fb3b-41dc-a3ab-a9e3e946b45b/student_lab_guide.md) to the students. Walk them through the `agent.py` code, particularly how the `TacticalCoachAgent` orchestrates the other two agents. Encourage them to modify the agent instructions and the database schema to fit their unique hackathon ideas.
