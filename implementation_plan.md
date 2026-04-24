# Enterprise Football AI Architecture Plan (Next '26 Edition)

Based on your request, I will dramatically expand the presentation to include a "Production-Grade Enterprise Architecture" section. This will show the students what a real-world, highly scalable system looks like, incorporating the latest announcements from Google Cloud Next '26.

## Proposed Presentation Additions

I will add a new section to the presentation script (`workshop_presentation.md`) covering the following pillars, complete with Mermaid diagrams for infographics and mindmaps.

### 1. Hardware & Network (The Infrastructure Foundation)
*   **Next '26 Update:** Highlight **TPU 8i** (optimized for low-latency agent inference) to process the high-throughput video streams. Mention the **Virgo Network** for ultra-fast, megascale data transfer between the camera edge and the cloud.
*   **Architecture:** Live stadium cameras -> Edge nodes -> Virgo Network -> GKE clusters running on TPU 8i.

### 2. Video Streaming & Ingestion
*   **Architecture:** RTSP streams processed by a highly available media server cluster (e.g., deployed on GKE). Frames are extracted and streamed directly to **Gemini 2.5 Flash / Gemini 2.0 Streaming APIs** for near-zero latency multimodal analysis.

### 3. Data Pipeline & The Intelligent Database
*   **Next '26 Update:** Introduce the **Agentic Data Cloud** and **Agentic Lakehouse**.
*   **Architecture:** 
    *   **Hot Data (In-Game):** Handled by **AlloyDB** (vector embeddings for instant play-matching).
    *   **Cold/Historical Data:** Handled by BigQuery/Agentic Lakehouse.
    *   **Agents:** The Data Agent uses the new **Data Agent Kit** to securely ground insights.

### 4. Agentic Orchestration
*   **Next '26 Update:** Transitioning from standalone ADK scripts to the **Gemini Enterprise Agent Platform** (the evolution of Vertex AI). Using **Memory Bank** for persistent game-state context across the 90 minutes.

### 5. UI, Visualization & Reporting
*   **Live UI:** Real-time dashboards built with custom React/Flutter frontends, subscribing to Agent Engine websockets for live tactical alerts.
*   **Post-Match Analytics:** Looker integrated with the Agentic Lakehouse for deep, granular BI reporting.

### 6. Infographics to be Generated
1.  **Mindmap:** A Mermaid mindmap breaking down the "Football AI Architecture Options" (Hardware, Network, DB, AI).
2.  **Architecture Flowchart:** A large-scale, detailed Mermaid flowchart showing the end-to-end data flow from the Stadium Camera to the Coach's iPad.

## User Review Required

> [!IMPORTANT]
> Please review this enterprise architecture plan. 
> 1. Does the inclusion of specific Next '26 tech (TPU 8i, Agentic Data Cloud, Gemini Enterprise Agent Platform) hit the right notes for your presentation?
> 2. Are you happy for me to proceed and update the `workshop_presentation.md` with the new script and Mermaid diagrams?
