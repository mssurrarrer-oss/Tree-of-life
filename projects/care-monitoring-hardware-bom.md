# Care Monitoring Hardware BOM

## Purpose
Procurement-ready bill of materials for a caregiver safety system with camera person detection and wearable vitals escalation.

## Tier 1: Essential Deployment (Fast Start)
1. 2 indoor cameras with person detection + RTSP/ONVIF.
2. 1 door camera for entry/exit alerts.
3. 1 wearable device with heart-rate and optional fall detection.
4. 1 mini-PC or always-on hub for automation routing.
5. 1 UPS battery backup for router + hub + primary camera.

## Tier 2: Resilient Deployment
1. Add 1 to 2 additional cameras for blind spots.
2. Add secondary caregiver contact device for failover.
3. Add smart plugs for device heartbeat monitoring.
4. Add local NAS or encrypted storage for short retention clips.

## Tier 3: Clinical Collaboration Ready
1. Add structured weekly summary export (CSV/PDF).
2. Add secure role-based account separation.
3. Add LTE backup modem for network outage alerts.
4. Add optional medication reminder integration.

## Suggested Budget Bands (Estimate)
- Tier 1: 800 to 1800 USD
- Tier 2: 1800 to 3500 USD
- Tier 3: 3500+ USD

## Compatibility Checklist
- Camera supports RTSP or ONVIF.
- Wearable supports API export or bridge connector.
- Hub can run Home Assistant or Node-RED.
- Device telemetry can be timestamped in ISO format.

## AI Hub Integration Targets
1. Trigger policy source: services/automation-framework/care-alert-triggers.json
2. Test harness: tools/run-care-alert-simulation.ps1
3. Daily validation artifacts: knowledge/checkins/YYYY-MM-DD-care-alert-simulation.md
4. Triage and decisions: knowledge/checkins/YYYY-MM-DD-notes.md
