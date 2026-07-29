# Inbox Triage Rubric

## Purpose
Standardize how personal and group inbox items are prioritized and routed so high-impact work is never missed.

## Inbox Lanes
1. personal: private or individual context under knowledge/inbox/personal/
2. group: shared mission context under knowledge/inbox/group/
3. shared: items in knowledge/inbox/ root not assigned to personal or group

## Priority Labels
- P0: score 80+ (immediate action)
- P1: score 60-79 (today)
- P2: score 40-59 (this cycle)
- P3: score 0-39 (backlog)

## Scoring Inputs
1. Urgency tokens in filename: critical, urgent, security, incident, outage, hotfix.
2. Operational tokens: firmware, update, patch, camera, electrical, automation, network.
3. Planning tokens: spec, roadmap, tracker, plan, constitution.
4. Recency bonus: modified in last 24h or 72h.
5. File support penalty: unsupported extension reduces score.

## Daily Flow
1. Run tools/triage-inbox.ps1.
2. Review generated top queue and priority distribution.
3. Promote all P0 and P1 items into same-day action set.
4. Capture final decisions in the daily check-in notes.

## Routing Rule
- P0 and P1: route to cloud coordination officer immediately for resolution planning.
- P2: route after stability task completion.
- P3: retain in backlog and revisit after new evidence.
