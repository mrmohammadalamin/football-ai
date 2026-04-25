class Agent:
    def __init__(self, name=None, model=None, instructions=None, sub_agents=None, output_schema=None):
        self.name = name
        self.model = model
        self.instructions = instructions
        self.sub_agents = sub_agents
        self.output_schema = output_schema

    def invoke(self, prompt: str) -> str:
        # Mocking the response of the orchestrator for the workshop prototype
        if "User Custom Question:" in prompt:
            question = prompt.split("User Custom Question:")[1].strip()
            return f'''{{
              "vision_analysis": "Answering user query regarding the video.",
              "referee_decision": "Custom query processed.",
              "commentary_text": "Here is the answer to your question: '{question}'. Yes, upon review, that was definitely a crucial moment in the match!",
              "excitement_level": 7,
              "fan_insight": "Fans are reacting to your question: '{question}'",
              "video_generation_prompt": "A tactical zoomed-in shot analyzing the specific query."
            }}'''
        
        # Parse timestamp to return dynamic commentary
        import re
        timestamp_match = re.search(r'timestamp (\d+) seconds', prompt)
        timestamp = int(timestamp_match.group(1)) if timestamp_match else 0
        
        if timestamp % 15 < 5:
            return '''{
              "vision_analysis": "Teams are holding formation in the midfield. Slow build-up play.",
              "referee_decision": "No infractions.",
              "commentary_text": "A tactical battle in the midfield as both teams look for an opening.",
              "excitement_level": 3,
              "fan_insight": "Crowd is patiently watching the build-up.",
              "video_generation_prompt": "Wide angle shot of the stadium."
            }'''
        elif timestamp % 15 < 10:
            return '''{
              "vision_analysis": "Sudden burst of pace down the wing. Cross whipped into the box.",
              "referee_decision": "Play continues, clean cross.",
              "commentary_text": "He breaks down the wing! A dangerous cross into the area...",
              "excitement_level": 6,
              "fan_insight": "Anticipation builds in the stands!",
              "video_generation_prompt": "Dynamic tracking shot of the winger."
            }'''
        else:
            return '''{
              "vision_analysis": "Striker connects with the cross! Spectacular volley on target.",
              "referee_decision": "Goal stands. No offside.",
              "commentary_text": "He shoots... and what a magnificent strike! Absolutely stunning!",
              "excitement_level": 10,
              "fan_insight": "Absolute bedlam in the stands! Fans are going wild!",
              "video_generation_prompt": "Slow motion replay of the volley."
            }'''
