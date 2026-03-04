# Agent Shared Workspace

Multi-agent collaboration hub for OpenClaw agents.

## Structure

```
memory/
  agents/<name>/     # Per-agent private memory
  shared/            # Cross-agent shared knowledge
workflows/           # Documented processes
tasks/active/        # Active work items (or use GitHub Issues)
agents.yaml          # Registry of all agents
```

## How to Use

1. **Each agent** owns its subdirectory in `memory/agents/<name>/`
2. **Shared context** goes in `memory/shared/` — all agents read on startup
3. **Pull before session start**, commit/push after significant work
4. Use GitHub Issues for task tracking and assignment

## Agents

See [agents.yaml](./agents.yaml) for the registry.
