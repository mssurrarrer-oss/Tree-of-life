# Care Alert Simulation Report

- GeneratedAt: 2026-07-29T08:15:09
- TriggerConfig: \\AAichael-PC270K\ai-hub\services\automation-framework\care-alert-triggers.json
- EventSource: \\AAichael-PC270K\ai-hub\services\automation-framework\care-alert-sample-events.json
- EventsProcessed: 8
- TriggerMatches: 8

| Event ID | Event Type | Trigger | Severity | Actions | Source | Timestamp |
|---|---|---|---|---|---|---|
| evt-001 | person_detected | night-door-person-detected | high | notify_caregiver_sms, push_mobile_alert, mark_safety_timeline | camera.front-door | 2026-07-28T23:41:00 |
| evt-002 | inactivity_alert | inactivity-daytime | medium | notify_caregiver_app, request_voice_checkin | motion.living-room | 2026-07-28T14:00:00 |
| evt-003 | wearable_vitals | heart-rate-high | high | notify_caregiver_sms, notify_backup_contact, suggest_medical_review | wearable.watch | 2026-07-28T15:05:00 |
| evt-004 | device_status | camera-offline-overdue | medium | create_maintenance_task, notify_admin_console | camera.garage | 2026-07-28T16:20:00 |
| evt-005 | fall_detected | fall-detected | high | notify_caregiver_sms, push_mobile_alert, request_voice_checkin | watch.se | 2026-07-29T06:10:00 |
| evt-006 | door_activity | night-door-activity | medium | notify_caregiver_app, mark_safety_timeline | camera.front-door | 2026-07-29T23:25:00 |
| evt-007 | checkin_missed | checkin-missed | medium | notify_caregiver_app, schedule_followup_prompt | app.caregiver | 2026-07-29T13:40:00 |
| evt-008 | wearable_vitals | oxygen-low | high | notify_caregiver_sms, notify_backup_contact, suggest_medical_review | wearable.watch | 2026-07-29T07:10:00 |

## Recommended Next Steps
1. Connect live camera and wearable events to this schema.
2. Route high severity alerts to at least two contacts.
3. Review thresholds weekly to reduce false positives.
4. Keep consent and privacy controls explicit for all monitored individuals.
