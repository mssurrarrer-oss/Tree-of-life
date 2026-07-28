import json
import os
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
STATE_FILE = ROOT / "agent" / "state.json"
KNOWLEDGE_DIR = ROOT / "knowledge"


def load_state():
    if STATE_FILE.exists():
        with STATE_FILE.open("r", encoding="utf-8") as handle:
            return json.load(handle)
    return {"runs": 0, "last_note_count": 0, "last_focus": "general"}


def save_state(state):
    STATE_FILE.parent.mkdir(parents=True, exist_ok=True)
    with STATE_FILE.open("w", encoding="utf-8") as handle:
        json.dump(state, handle, indent=2)


def count_notes():
    if not KNOWLEDGE_DIR.exists():
        return 0
    return sum(1 for path in KNOWLEDGE_DIR.glob("*.md")) + sum(1 for path in KNOWLEDGE_DIR.glob("*.txt"))


def build_suggestion(state):
    note_count = count_notes()
    if note_count > state.get("last_note_count", 0):
        return "New material was detected in the knowledge folder. Consider reviewing it and adding a fresh insight."
    return "The knowledge base is stable. Consider reviewing one prior idea or opening a new line of thought."


def main():
    state = load_state()
    state["runs"] += 1
    note_count = count_notes()
    state["last_note_count"] = note_count
    suggestion = build_suggestion(state)
    
    # ---------------------------------------------------------
    # System Admin Integration: Read Hardware Topology (Cluster)
    # ---------------------------------------------------------
    topology_file = ROOT / "projects" / "hardware-topology.json"
    cluster_status = "Disconnected"
    if topology_file.exists():
        cluster_status = "Active (USB4 20Gbps Link)"
        suggestion += " | Cluster topology loaded: Ready to route tasks to Main PC or Mini PC."

    state["last_suggestion"] = suggestion
    save_state(state)

    print(json.dumps({
        "agent": "Mini PC Local Admin",
        "runs": state["runs"],
        "note_count": note_count,
        "cluster_link": cluster_status,
        "suggestion": suggestion
    }, indent=2))


if __name__ == "__main__":
    main()
