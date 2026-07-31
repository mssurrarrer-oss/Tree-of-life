# Cross-Node Inference Bridge (LMLink / LM Studio Server)

## Objective
Establish a persistent, low-latency API bridge across the USB4 20Gbps network so the Mini PC (and cloud coordinators like Codex) can silently pass heavy tasks to Gemma operating on the Main PC.

## Configuration on Main PC (The Heavy Node)
1. **Open LM Studio**.
2. Load your highest-parameter model (e.g., Gemma 4 12B or deepseek-coder) entirely into the AMD RX 9070XT's VRAM.
3. Navigate to the **Local Server** tab (usually indicated by the server icon `<->`).
4. Set the **Port** to `1234` (default) or `11434` (Ollama compatibility mode).
5. Ensure **CORS** is enabled (Cross-Origin Resource Sharing).
6. Enable the server to listen on the local network adapter (e.g., `10.0.0.2` rather than just `localhost`/`127.0.0.1`).
7. Click **Start Server**.

## Configuration on Mini PC (The Admin Node)
The Mini PC can now seamlessly make requests to the Main PC without needing to wake Azure/Google cloud endpoints.

### Quick Test via PowerShell (Run from Mini PC Terminal)
```powershell
$MainPC_IP = "10.0.0.2"
$Port = "1234" # Change to 11434 if using Ollama mode
$Endpoint = "http://${MainPC_IP}:${Port}/v1/chat/completions"

$Payload = @{
    model = "gemma-4-12b" # Must match loaded model identifier
    messages = @(
        @{ role = "system"; content = "You are the Local Sub-Architect." },
        @{ role = "user"; content = "Confirm network bridge operational status." }
    )
} | ConvertTo-Json

Invoke-RestMethod -Uri $Endpoint -Method Post -Body $Payload -ContentType "application/json"
```

## Symbiosis with Cloud (Codex & Microsoft Copilot)
- **Primary / Secondary Strategy**: Local Gemma handles *Hardware, Privacy-Sensitive Data, and Heavy Code Drafting*.
- **Cloud Escapes**: If Gemma lacks specific worldly context or bleeding-edge API docs, Codex (or Microsoft Copilot) acts as the cloud-peer to reach across the internet, retrieve the updated docs, ingest them into `knowledge/inbox/`, and feed them back down to Gemma.
- This creates an escalating "Diamond" architecture: 
  - Operator (Center)
  - Mini PC orchestrator (Frontline)
  - Main PC Gemma (Heavy Local Backing)
  - Cloud / MS Copilot (External Reach)
