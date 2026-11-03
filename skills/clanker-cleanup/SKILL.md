---
name: clanker-cleanup
description: Use when the user says a branch, PR, script, config or runbook is overcomplicated, over-engineered or "too much optimization", or asks to simplify a change before review so it stays simple and straightforward.
---

# clanker-cleanup

Make a change only as complex as its job needs. Remove what the change doesn't need, keep what it does, and never undo a decision the user made. These rules apply to any language and any repo. Comment-only cleanup is `deslop`; write everything to the user per `clanker-conduct`.

## Before cleaning up

### Scope

The scope is the branch diff against its base (`git diff <base>...HEAD`) plus every doc that describes the change: README, runbook, design doc, PR description, examples. Leave code outside the diff alone.

### Write down what must stay

Before reviewing, list:
- **Must keep:** behavior the user or the design requires, taken from the design doc, the PR description and the conversation.
- **User decisions:** choices the user made in conversation. Search the conversation when unsure. E.g. the user chose to keep an old endpoint for existing clients, so don't delete it as unused.

### What simpler means

Simpler means fewer things a reader must track: lines, options, branches, files or concepts. A finding counts only if it reduces one of these without adding to another.

## What to remove

### Options nobody sets

A parameter, flag, prop or config field that every caller sets to the same value, or never sets, becomes a constant. E.g. `fetch(url, timeout_ms=5000)` where no caller passes `timeout_ms`.

### Values equal to the default

Delete settings that restate what already happens. E.g. passing `retries: 0` to a client whose default is `0`.

### Checks for cases that can't happen

Delete checks that earlier code or the type system already guarantees, and checks on values the code produces itself. E.g. re-checking a string against the regex it already passed, or a null check on a non-optional value.

### Repeated work

Compute a value once and pass the result. E.g. normalizing a name to validate it, then normalizing it again at every use.

### Code that something existing already does

Use the language, the standard library, an existing dependency or an existing helper in the repo instead of a hand-written version. E.g. a hand-written retry loop around a client that has built-in retries. Don't change shared code to make it fit.

### Abstractions with one user

Inline a base class, interface, factory, wrapper or registry that has one implementation or one caller. Add it back when a second user exists.

### Patterns copied where they do nothing

Delete setup copied from another context where it has no effect here. E.g. production redundancy on a dev-only service, or a cache around a function called once per process.

### Optimization without a measured need

Delete optimization that adds code without a measured problem behind it. Keep a faster version only when it is also simpler.

### Workarounds instead of fixes

Replace a special case that handles one bad result with a fix to its cause, when the fix is less code.

### Leftovers from building the change

Delete one-off scripts (benchmarks, debug helpers) and numbers that held only on one machine or run, unless the change needs them to run or be maintained.

### Docs that repeat or guess

- Write each fact in one place. Delete doc text that restates code, duplicate steps, and code output that repeats a doc. E.g. a script that prints the setup steps the README also lists should print one line pointing to the README.
- Delete speculative tips. Write full commands instead of shell aliases or helper functions.

## What not to change

Skip a finding, and report it under "Kept on purpose", when it:
- reverses a user decision;
- changes shared or production code outside the diff;
- renames or moves code without removing any.

A behavior change is fine when the behavior wasn't required. Report each one with its effect.

## Doing the cleanup

1. Review the diff against the rules above. Each finding names the file, the line, what it costs, and the simpler replacement. On a large diff, split the review across read-only agents launched together, one per angle (removals, reuse, repeated work, root causes), and give each the scope, both lists and these rules.
2. If the user asked only for a review, report the findings and stop. Otherwise apply the findings that pass "What not to change", then regenerate generated files (lockfiles, snapshots, generated code).
3. Run the checks the repo already uses: type check, lint, tests, build. Update tests that only assert old wording.
4. Sync every doc in scope, including the PR description.
5. Make one commit with a comma-separated message, e.g. `remove unused timeout option, inline config loader`. Push only if the user authorized pushing this branch.

## Report

1. One line: commit, lines removed and added.
2. **Removed:** bullets.
3. **Behavior changes:** each with its effect.
4. **Kept on purpose:** each skipped finding and why.
5. **Checks:** what ran, and what didn't (e.g. anything that needs live infrastructure).
