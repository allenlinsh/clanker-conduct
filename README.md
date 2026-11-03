# clanker-conduct

Agent skills ([Agent Skills](https://agentskills.io)) for Claude, Cursor, Codex, and other compatible agents.

| Skill | Does |
| --- | --- |
| [`clanker-conduct`](skills/clanker-conduct/SKILL.md) | My preferences for how agents talk and code |
| [`clanker-cleanup`](skills/clanker-cleanup/SKILL.md) | Simplifies an overcomplicated branch, PR, script, config or runbook, keeping required behavior and the user's decisions |
| [`tmux`](skills/tmux/SKILL.md) | Lets an agent open tabs and splits in its starting tmux session, run and read commands in them, and close what it opened |

## Install

```bash
# Choose from all skills
npx skills add allenlinsh/clanker-conduct

# Or install one
npx skills add allenlinsh/clanker-conduct --skill tmux
```

Or import the GitHub repo URL in your agent's skills / rules UI.

## Claude Code status line

[`claude-code/statusline-command.sh`](claude-code/statusline-command.sh) shows the directory and git branch, the model, context window usage, and 5-hour and 7-day rate limit usage:

```text
~/code/my-repo ⎇ main › Opus 5.5 › ctx 11% › 5h:27% 7d:43%
```

Context usage turns yellow at 60% and red at 80%. Rate limits turn yellow at 60% and red at 85%, and appear only when Claude Code reports them. It needs `jq`, `git`, and a [Nerd Font](https://www.nerdfonts.com) for the branch icon and separators.

```bash
curl -fsSL https://raw.githubusercontent.com/allenlinsh/clanker-conduct/main/claude-code/statusline-command.sh -o ~/.claude/statusline-command.sh
chmod +x ~/.claude/statusline-command.sh
```

Then add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline-command.sh"
  }
}
```

## Layout

```text
.
├── claude-code/
│   └── statusline-command.sh   # Claude Code status line
└── skills/
    └── <name>/
        ├── SKILL.md       # required — frontmatter + instructions
        ├── scripts/       # optional executable helpers
        ├── references/    # optional on-demand docs
        └── assets/        # optional templates / static files
```
