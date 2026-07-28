# Persistent Agent Concept

## Goal
Create a lightweight, always-available local agent layer that can shift between modes and preserve a limited working memory.

## Design idea
- Keep a small working memory of recent tasks, notes, and priorities.
- Let the agent switch between profiles such as Language Guardian, Creative Builder, or Ethics Steward.
- Use a scheduler or simple trigger system to check in at intervals.
- Keep the agent lightweight and local-first.

## Practical options
- Task scheduler: Windows Task Scheduler for periodic reminders or scripted actions.
- Local watcher: a small script that checks for new files or notes and updates the memory index.
- Agent loop: a lightweight service that maintains a short-term memory buffer and surfaces helpful prompts.

## Recommendation
Start simple: a scheduled reminder and memory-refresh script is enough to validate the concept before building anything heavier.
