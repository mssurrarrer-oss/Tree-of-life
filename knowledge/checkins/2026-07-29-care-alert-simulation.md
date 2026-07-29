# Care Alert Simulation Report

- GeneratedAt: 2026-07-29T05:01:02
- TriggerConfig: D:\ai-hub\services\automation-framework\care-alert-triggers.json
- EventSource: D:\ai-hub\services\automation-framework\care-alert-sample-events.json
- EventsProcessed: 4
- TriggerMatches: 4

| Event ID | Event Type | Trigger | Severity | Actions | Source | Timestamp |
|---|---|---|---|---|---|---|
| evt-001 | person_detected | night-door-person-detected | high | notify_caregiver_sms, push_mobile_alert, mark_safety_timeline | camera.front-door | 2026-07-28T23:41:00 |
| evt-002 | inactivity | inactivity-daytime | medium | notify_caregiver_app, request_voice_checkin | motion.living-room | 2026-07-28T14:00:00 |
| evt-003 | wearable_vitals | heart-rate-high | high | notify_caregiver_sms, notify_backup_contact, suggest_medical_review | wearable.watch | 2026-07-28T15:05:00 |
| evt-004 | device_status | camera-offline-overdue | medium | create_maintenance_task, notify_admin_console | camera.garage | 2026-07-28T16:20:00 |

## Recommended Next Steps
1. Connect live camera and wearable events to this schema.
2. Route high severity alerts to at least two contacts.
3. Review thresholds weekly to reduce false positives.
4. Keep consent and privacy controls explicit for all monitored individuals.
