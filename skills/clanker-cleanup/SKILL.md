---
name: clanker-cleanup
description: Use when the user says a branch, PR, script, config or runbook is overcomplicated, over-engineered or "too much optimization", or asks to simplify a change before review so it stays simple and straightforward.
---

# clanker-cleanup

Make a change only as complex as its job needs. Remove what the design doesn't need, keep what it does, and never undo a decision the user made. Comment-only cleanup is `deslop`; write everything to the user per `clanker-conduct`.

## 1. Scope and two lists

- Scope: the branch diff against its base (`git diff <base>...HEAD`), plus every doc that describes it: README or runbook, design doc, PR description, examples.
- Before reviewing, write down:
  - **Must keep:** behavior the design or user requires, taken from the design doc, the PR description and the conversation.
  - **User decisions:** choices the user made in conversation. Search the transcript when unsure. Example: "the web form takes the served model name", which rules out going back to full provider paths.

## 2. Review: four read-only agents, launched in one message

Give each agent the repo path, the diff command, the file list, both lists, and this rule: report only changes that make the result simpler. Each finding gives file, line, summary, cost, and the simpler replacement.

| Angle | Looks for |
| --- | --- |
| Simplification | The smells below |
| Reuse | An existing constant or helper that fits without changing shared or production code |
| Waste | Repeated work, only when the cheaper version is also simpler. Lists premature optimization to delete. |
| Root cause | Special cases or workarounds where a deeper fix is also less code |

## 3. Smells

| Smell | Example | Simpler form |
| --- | --- | --- |
| Shell helper or alias in docs | `k() { kubectl --context=... "$@"; }` | Full commands; state the context once |
| Option nobody passes | `dryRun` prop, `--target-mb`, `idleMs = IDLE_MS` parameter | Constant |
| Config field with one value everywhere | `max_inflight_body_bytes` = 1 GiB in every config | Constant in code |
| Deny-list of values the code generates | List of flags a config may not set | Put generated values last so they win |
| Pattern copied where it does nothing | Script-hash annotation on a CronJob; production HA (2 replicas, PodDisruptionBudget, anti-affinity) on a dev service | Delete |
| Probe or timeout that only adds a deadline | `startupProbe` with no liveness probe | Readiness probe only |
| Value equal to the default | `terminationGracePeriodSeconds: 30` | Delete |
| Guard for a case that can't happen | Re-checking a value already validated by the same regex | Delete |
| Second copy of the runbook in code output | Generator printing the apply commands | One line pointing to the runbook |
| Measurement tooling or numbers whose result depends on context | Load-test script; throughput in configs | Delete |
| Value computed again after validation | Label value converted once to validate, then 14 more times | Compute once, pass the result |
| Hand-written code for a library one-liner | PNG encoder | The library call |
| Runbook text restating code, duplicate steps, speculative tips | `logs -f` next to `wait` for the same Job | Cut |

## 4. Triage

Apply a finding when the result is simpler and every Must keep item still holds. Skip it, and list it under "Kept on purpose", when it:
- reverses a User decision;
- changes shared or production code outside the diff;
- renames or moves code without removing any.

A behavior change is fine when the behavior wasn't required. List each one with its observable effect.

## 5. Apply and verify

- Edit, then regenerate generated files (manifests, snapshots, lockfiles).
- Run the type check, lint, tests and render or synth. Update tests that only assert old wording.
- Sync every doc in scope, including the design doc and the PR description.
- One commit with a comma-separated message. Push only if the user authorized pushing this branch.

## 6. Report

1. One line: commit, lines removed and added.
2. **Removed:** bullets.
3. **Behavior changes:** each with its effect.
4. **Kept on purpose:** each finding and why.
5. **Checks:** what ran, and what didn't (for example, never run against a live cluster).
