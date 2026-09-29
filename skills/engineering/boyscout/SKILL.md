---
name: boyscout
description: "Leave the repository a little better than you found it. Mine recent commits, pull or merge requests, issues, and comments (last 30 days by default) for patterns that keep going wrong or cases that were missed, and pin one down with a deterministic test, plus a minimal fix if it fails. Proposes first; implements only after the user confirms. Use when the user asks to boyscout the repo, add a regression test for recent bugs, or pick up missed edge cases from reviews."
---

# Boyscout

Find one thing that recently went wrong, or was missed, and pin it down with a deterministic test so it can't silently happen again. If the test fails on the current code, include the minimal fix. Propose first; change nothing until the user agrees.

## Process

### 1. Pin the window

- Use the user's window (a date, ref, or tag), or default to the last 30 days.
- For a ref or tag, get its date with `git log -1 --format=%cs <ref>`.
- State the window as `<date>..today`.

### 2. Gather the signals

Each source is optional. If one can't be read, say which and why, and carry on.

- **Commits**: `git log --reverse --since=<date> --format='%h %cs %s%n%n%b'`
- **Fixes and reverts, with their files**: `git log --since=<date> -i -E --grep='fix|revert|regress|hotfix|bug' --name-only --format='%h %cs %s'`
- **Pull or merge requests, and issues**, from the tracker in `git remote get-url origin`:
  - GitHub: `gh pr list` and `gh issue list` with `--state all --search "updated:>=<date>" --json number,title,state,labels,url`; then `gh pr view <n> --comments` or `gh issue view <n> --comments`, and inline review comments with `gh api repos/{owner}/{repo}/pulls/<n>/comments --jq '.[] | {path, line, body}'`.
  - GitLab: `glab api "projects/:id/merge_requests?state=all&updated_after=<date>"` and the same for `issues`; then `glab mr view <n> --comments` or `glab issue view <n> --comments`.
  - Another host, or a missing or signed-out CLI: say so and use git only.
- **Markers** in recently changed files: `git log --since=<date> --name-only --format= | sort -u | xargs grep -nE 'TODO|FIXME|HACK|XXX' 2>/dev/null`
- **Test setup**: where tests live and how they run (`package.json`, `Makefile`, CI config).
- **Standards**: `CONTRIBUTING.md`, `CLAUDE.md`, `AGENTS.md`, and similar docs, if present.

### 3. Collect candidates

- **Patterns that go wrong**: the same code fixed more than once; a fix reverted or fixed again; the same class of bug in several places (quoting, off-by-one, empty input, paths); the same review complaint on different PRs or MRs.
- **Things missed**: bug fixes without a reproducing test; edge cases raised in review or issues but not handled; TODOs describing a known wrong case; requirements no test covers.

Every candidate needs evidence: a commit SHA, a link, or a quoted comment. Drop anything you can't point to.

### 4. Pick one

- Keep only candidates that are:
  - Deterministically testable: fixed inputs; no network, wall clock, randomness, sleeps, or ordering dependence; runs in the repo's harness (or the smallest one that fits, if there is none, and say so).
  - Small: one test, plus at most a minimal fix.
  - Unclaimed: not covered by an open PR, MR, or assigned issue.
- Rank by how likely the problem is to recur, over effort. Choose the top one, and keep up to three runners-up.
- If nothing survives, say so and stop.

### 5. Propose and stop

Report:

- **Problem**: the pattern or missed case, in one or two sentences.
- **Evidence**: the quoted comment, commit, or issue, with its link or SHA.
- **Test**: what it asserts, its inputs and expected result, and the file it goes in.
- **On current code**: whether you expect the test to fail (a fix is included, and name the files it touches) or pass (it's a regression guard only).
- **Runners-up**: one line each, with their evidence.

Ask the user to confirm, pick a runner-up instead, or stop. Don't edit anything until they answer.

### 6. Implement on OK

- If you are on the default branch, create a branch first.
- Write the test, matching the tests around it, and run it on the current code.
- For a bug that's already fixed, prove the test would have caught it: in a throwaway worktree at the commit before the fix (`git worktree add <tmp> <fix-sha>^`), copy the test in and run it. It must fail. Then `git worktree remove --force <tmp>`.
- If the test fails on the current code, make the minimal fix and re-run until it passes.
- Run the new test three times to confirm it's stable, then the full suite.
- Report the change and the test output. Don't commit or open a PR unless asked.

## Sources

- The boy scout rule, as applied to code by Robert C. Martin in *Clean Code* and *97 Things Every Programmer Should Know*.
