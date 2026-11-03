---
name: clanker-cleanup
description: Use when the user says a change is overcomplicated, over-engineered or full of AI slop (unnecessary code, options, checks, comments or docs), or asks to simplify a branch, PR, script, config or runbook before review.
---

# clanker-cleanup

Remove what a change doesn't need and keep what it does. The standard comes from the task and the surrounding code, not from a list of patterns, so it applies to any language, codebase or writing style. Write everything to the user per `clanker-conduct`.

## The standard

### Delete what nothing needs

For each part of the change (a line, option, check, comment, doc sentence or file), ask: if this were deleted, what would break, and who would lose information they need? If nothing breaks and nobody loses anything, delete it.

E.g. a `timeout` parameter that no caller passes: deleting it changes nothing, so make it a constant. A null check on an API response: deleting it can crash on bad data, so keep it.

### When unsure, keep it

If you can't tell what deleting something would affect, keep it and list it in the report with your question. A leftover line costs a reviewer a minute; a removed safeguard can break production.

### Match the surrounding code

The cleaned change should read like the rest of the codebase: the same amount of error handling, validation, abstraction and documentation as nearby code written by the codebase's authors. Where the change does more than nearby code, that is usually what to remove. Where it does less, leave it; adding is not this skill's job.

### Don't change existing behavior

Cleanup changes how the code is written, not what it does. Behavior that existed before the change stays. Behavior the change added stays if the task needs it; if the task doesn't need it, removing it is the point of the cleanup. Report every behavior change with its effect.

### Keep the user's decisions

Never undo a choice the user made, even if it looks unnecessary. Take decisions from the conversation, the design doc and the PR description, and search the conversation when unsure.

### Simpler means less to read

A cleanup must leave less for a reader to understand. Don't replace removed code with a new abstraction, rename or move code without removing any, or change code outside the change.

### Say things once, and only what the reader needs

Comments, docs, PR descriptions and output messages state what the reader can't get from the code, once. Delete text that restates the code, repeats another doc, or adds tips nobody asked for.

## Doing the cleanup

1. Scope: the branch diff against its base (`git diff <base>...HEAD`) and every doc that describes it: README, design doc, PR description, examples.
2. Write down what the change must keep and the user's decisions.
3. Review each part of the diff against the standard. Each finding gives the file, the line, what deleting it would affect, and the simpler form. On a large diff, split the review across read-only agents launched together, and give each the scope, both lists and this standard.
4. If the user asked only for a review, report the findings and stop. Otherwise apply them, regenerate generated files, and run the checks the repo already uses. Update tests that only assert old wording.
5. Sync every doc in scope, including the PR description.
6. Make one commit with a comma-separated message. Push only if the user authorized pushing this branch.

## Report

1. One line: commit, lines removed and added.
2. **Removed:** bullets.
3. **Behavior changes:** each with its effect.
4. **Kept:** findings you skipped or weren't sure about, and why.
5. **Checks:** what ran, and what didn't.
