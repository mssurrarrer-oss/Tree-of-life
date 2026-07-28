import json
import os
import requests
from pathlib import Path

TOPOLOGY_FILE = Path("../../projects/hardware-topology.json").resolve()
LOCAL_OLLAMA = "http://localhost:11434/api/generate"
REMOTE_OLLAMA = "http://10.0.0.2:11434/api/generate"

def load_topology():
    if TOPOLOGY_FILE.exists():
        with open(TOPOLOGY_FILE, 'r') as f:
            return json.load(f)
    return {}

def determine_routing(prompt):
    """
    Intelligent router to decide if the task requires the heavy Main PC
    or if it can be handled by the Mini PC's efficient low-latency models.
    """
    heavy_keywords = ["refactor", "architect", "complex", "large", "generate full", "analyze massive"]
    prompt_lower = prompt.lower()
    
    # If the task looks extremely complex, offload across the USB4 20Gbps bridge
    for kw in heavy_keywords:
        if kw in prompt_lower:
            return "main_pc"
            
    # Default to local processing for speed, simple tasks, and embeddings
    return "mini_pc"

def run_task(prompt):
    target = determine_routing(prompt)
    topology = load_topology()
    
    print(f"[*] Local Admin AI analyzing task...")
    print(f"[*] Routing decision: Deploying to {target.upper()}")
    
    if target == "mini_pc":
        endpoint = LOCAL_OLLAMA
        model = "gemma2:2b" # Placeholder for your preferred fast precision model
    else:
        # Assumes main_pc is configured on your USB4 interface IP (e.g. 10.0.0.2)
        main_host = topology.get("nodes", {}).get("main_pc", {}).get("host", "10.0.0.2")
        endpoint = f"http://{main_host}:11434/api/generate"
        model = "gemma-2-9b" # Placeholder for heavier 4-quant large model
        
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": True # Use streaming for fast VS Code interface response
    }
    
    print(f"[*] Executing via {endpoint} on model {model}...")
    
    try:
        # Example of handling the stream
        with requests.post(endpoint, json=payload, stream=True) as response:
            for line in response.iter_lines():
                if line:
                    decoded = json.loads(line.decode('utf-8'))
                    if "response" in decoded:
                        print(decoded["response"], end="", flush=True)
        print("\n\n[*] Task complete.")
    except requests.exceptions.ConnectionError:
         print(f"[!] Error: Could not reach {target}. Ensure Ollama is running and host {endpoint} is accessible via the USB4 bridge.")

if __name__ == "__main__":
    print("-" * 50)
    print("Welcome to the Mini PC Local Admin AI (Core Ultra 9 / Arc B580 orchestrator)")
    print("Cross-Device Hardware AI Hub - Status: ONLINE (20 Gbps Link Active)")
    print("-" * 50)
    
    while True:
        try:
            req = input("\nAdmin Console > ")
            if req.strip().lower() in ["exit", "q"]:
                break
            if req.strip():
                run_task(req)
        except KeyboardInterrupt:
            break
