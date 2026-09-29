---
name: code-review
description: "Review the commits between a fixed point (commit, branch, tag, or merge-base) and HEAD in two parallel passes: one against the repo's documented coding standards plus Fowler's code smells, and one against the spec (linked issues or merge requests, or a spec the user gives). Reports standards and spec findings separately. Use when the user asks to review a branch, a commit range, or the changes since a ref, or to check work against its issue or the contributing guidelines. Covers committed changes only, not uncommitted work."
---

# Code Review

Review everything committed between a pinned fixed point (a commit, branch, tag, or merge-base) and `HEAD`. The diff shows what changed; the commit messages show what was intended. When a spec is available (linked issues or merge requests, or a spec the user gives), review the diff against that spec too. Also check the diff against the repo's coding standards.

## Process

### 1. Pin the fixed point

- Use the fixed point the user specified: a commit, branch, tag, or "merge-base with `<branch>`".
- If none was given, ask the user for one and stop until they answer. Don't guess. Offer likely candidates, such as `git merge-base origin/main HEAD` or the latest tag (`git describe --tags --abbrev=0`).
- Resolve it to a commit SHA:
  - Commit, branch, or tag: `git rev-parse --verify "<ref>^{commit}"`
  - Merge-base: `git merge-base <branch> HEAD`
- If it doesn't resolve, report the error and ask again.
- If `git merge-base --is-ancestor <sha> HEAD` fails, the fixed point is not in `HEAD`'s history, so the diff would also include its own unrelated changes, reversed. Warn the user and offer `git merge-base <sha> HEAD` instead.
- State the pinned range as `<ref> (<short-sha>)..HEAD (<short-sha>)`. Use that SHA, not the ref, in every later command, so the range stays fixed even if a branch moves.

### 2. Capture the changes

- Commit messages, oldest first: `git log --reverse --format='%h %s%n%n%b' <sha>..HEAD`
- Diff summary: `git diff --stat <sha>..HEAD`
- Full diff: `git diff <sha>..HEAD`
- If the log is empty, tell the user there is nothing to review and stop.
- If `git status --porcelain` shows uncommitted changes, tell the user they are not part of this review.
- Use the commit messages as the stated intent of the changes. In the later steps, check the diff against that intent.

### 3. Determine the spec source

- If the user pointed at a spec (a file, URL, issue, or doc), use it.
- Otherwise, extract issue references from the commit messages:
  `git log --format=%B <sha>..HEAD | grep -oE '([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)?[#!][0-9]+' | sort -u`
  This catches `#123`, `Closes #123`, `Fixes #123`, `Resolves #123`, `owner/repo#123`, and GitLab `!123` (a merge request).
- Identify the tracker from `git remote get-url origin` and fetch each reference:
  - GitHub: `gh issue view <n> --comments`. If `<n>` is a pull request, use `gh pr view <n> --comments`. Add `-R owner/repo` for cross-repo references.
  - GitLab: `#n` → `glab issue view <n> --comments`, and `!n` → `glab mr view <n> --comments`.
  - If it's another host, or the CLI is missing or not signed in, say so and treat the reference as unresolved.
- If no spec was found or resolved, ask the user where the spec is. If they say there isn't one, skip spec checks and note in the report that the diff was reviewed against the commit messages only.
- List each spec source used (the reference and its title), and extract its requirements and acceptance criteria. In the later steps, check the diff against them, and flag anything that isn't covered or goes beyond the spec.

### 4. Identify the coding standard

- Read whichever of these exist that document how code should be written, repo-wide and in subdirectories that contain changed files:
  - Contributor docs: `CONTRIBUTING.md`
  - Style guides and code style docs: `STYLEGUIDE.md`, `CODE_STYLE.md`
  - Agent docs: `CLAUDE.md`, `AGENTS.md`, `.github/copilot-instructions.md`, `.cursor/rules/`
- Precedence:
  - A doc closer to the changed file beats a repo-wide one.
  - Written docs beat the baseline below.
- Where the docs say nothing, follow the conventions of the code around the change.
- Baseline, Fowler's code smells (*Refactoring*, 2nd ed.). Check only the changed code, and only where the repo's standards don't say otherwise:
  - **Mysterious Name**: a name doesn't reveal what the function, variable or field does. → Rename it (Change Function Declaration, Rename Variable, Rename Field).
  - **Duplicated Code**: the same code structure appears in more than one place. → Extract Function; Slide Statements to line up similar code first; Pull Up Method for duplicates in sibling subclasses.
  - **Long Function**: a function does so much that it's hard to understand. → Extract Function (let comments, conditionals and loops point to the seams); Decompose Conditional; Split Loop.
  - **Long Parameter List**: so many parameters that calls are confusing. → Introduce Parameter Object; Preserve Whole Object; Replace Parameter with Query; Remove Flag Argument.
  - **Global Data**: data anyone can modify from anywhere, so nobody knows who changes it. → Encapsulate Variable and narrow its scope.
  - **Mutable Data**: updates to data cause unexpected effects elsewhere. → Encapsulate Variable; Split Variable; Separate Query from Modifier; Replace Derived Variable with Query.
  - **Divergent Change**: one module changes for several unrelated reasons. → Split Phase; Extract Class; Move Function.
  - **Shotgun Surgery**: one change requires many small edits across many modules. → Move Function / Move Field to bring the pieces together; Combine Functions into Class.
  - **Feature Envy**: a function uses another module's data more than its own. → Move Function to where the data lives (Extract Function first if only part is envious).
  - **Data Clumps**: the same group of data items keeps appearing together. → Extract Class; Introduce Parameter Object; Preserve Whole Object.
  - **Primitive Obsession**: primitives stand in for domain concepts such as money, ranges or IDs. → Replace Primitive with Object; Replace Type Code with Subclasses.
  - **Repeated Switches**: the same switch or if-chain on the same condition appears in several places. → Replace Conditional with Polymorphism.
  - **Loops**: a loop hides what's being done to a collection. → Replace Loop with Pipeline (map, filter, reduce).
  - **Lazy Element**: a function or class that doesn't earn its keep. → Inline Function; Inline Class; Collapse Hierarchy.
  - **Speculative Generality**: hooks, parameters or abstractions for needs that don't exist yet. → Remove them (Inline Function or Class, Collapse Hierarchy, Change Function Declaration, Remove Dead Code).
  - **Temporary Field**: a field that is only set in certain situations. → Extract Class for the field and its code; Introduce Special Case.
  - **Message Chains**: a client navigates a chain of objects (`a.b().c().d()`). → Hide Delegate; Extract Function and Move Function to shorten the chain.
  - **Middle Man**: a class delegates most of its work to another class. → Remove Middle Man; Inline Function.
  - **Insider Trading**: modules trade too much internal data and become tightly coupled. → Move Function or Move Field; Hide Delegate; Replace Subclass with Delegate.
  - **Large Class**: a class has too many fields or too much code. → Extract Class; Extract Superclass; Replace Type Code with Subclasses.
  - **Alternative Classes with Different Interfaces**: classes that should be interchangeable have different interfaces. → Change Function Declaration to align them; Move Function; Extract Superclass.
  - **Data Class**: a class with only fields and getters and setters, whose behavior lives elsewhere. → Encapsulate Record; Remove Setting Method; move the behavior in with Move Function.
  - **Refused Bequest**: a subclass doesn't use or want what it inherits. → Push Down Method or Push Down Field; Replace Subclass or Superclass with Delegate.
  - **Comments**: comments that explain unclear code rather than why. → Extract Function or rename until the comment is unnecessary; Introduce Assertion for stated assumptions. Keep comments that explain *why*.
  - Name the smell and the refactoring that fixes it.
- Summarize the standards that apply, with their sources (file paths), for use in the later steps. If the repo has no such docs, say that only the surrounding code and the baseline apply.

### 5. Spawn the reviewers in parallel

Launch both subagents in the same turn so they run in parallel. Subagents can't see this skill or this conversation, so each prompt must be self-contained: paste everything listed below in full, and use the pinned SHA, not the ref.

**Standards reviewer.** The prompt includes:

- The diff command: `git diff <sha>..HEAD`
- The commit list: the output of `git log --reverse --format='%h %s%n%n%b' <sha>..HEAD`
- The standards sources found in step 4 (file paths), to read in full.
- The complete code-smell list from step 4, pasted verbatim.
- The brief, verbatim:
  > Report, per file/hunk where relevant, (a) every place the diff violates a documented standard: cite the standard (file + the rule); and (b) any baseline smell you spot: name it and quote the hunk. Distinguish hard violations from judgement calls: documented-standard breaches can be hard, but baseline smells are always judgement calls, and a documented repo standard overrides the baseline. Skip anything tooling enforces. Under 400 words.

**Spec reviewer.** The prompt includes:

- The diff command: `git diff <sha>..HEAD`
- The commit list: the output of `git log --reverse --format='%h %s%n%n%b' <sha>..HEAD`
- The spec from step 3: a file path to read, or the fetched content (issue or merge request bodies and comments) pasted in full.
- The brief, verbatim:
  > Report: (a) requirements the spec asked for that are missing or partial; (b) behaviour in the diff that wasn't asked for (scope creep); (c) requirements that look implemented but where the implementation looks wrong. Quote the spec line for each finding. Under 400 words.

If step 3 found no spec, don't launch the spec reviewer. Record that it was skipped for the final report.

### 6. Aggregate the results

Report the two reviews in separate sections, in this order:

- **Standards findings**: the standards reviewer's findings, each under its own heading, verbatim or lightly cleaned. Keep its split between hard violations and judgement calls.
- **Spec findings**: the spec reviewer's findings, each under its own heading, verbatim or lightly cleaned. If the spec reviewer was skipped, say so here: no spec was found, so the diff was reviewed against the commit messages only.

Don't merge findings across the two sections, and don't re-rank one section against the other. The two reviews answer different questions, and blending them lets one mask the other. Code can meet every standard and still miss the spec, or implement the spec exactly while breaking the standards. Keeping them apart shows each result on its own terms.

## Sources

- [Matt Pocock's `code-review` skill](https://github.com/mattpocock/skills/blob/main/skills/engineering/code-review/SKILL.md): an inspiration for this skill.
- Martin Fowler, *Refactoring* (2nd ed.): the code-smell baseline in step 4.
