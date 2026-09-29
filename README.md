# Skills

Roald's agent skills for engineering: small, plain `SKILL.md` files for Claude Code and other agents that read `~/.agents/skills`.

## Installation

```bash
git clone https://github.com/roaldnefs/skills.git
cd skills
scripts/link-skills.sh
```

`link-skills.sh` symlinks every skill into `~/.claude/skills` and `~/.agents/skills`, so a `git pull` keeps them up to date. It never overwrites real files, or links that point elsewhere. Run `scripts/list-skills.sh` to see all skills.

## Skills

### Engineering

- **[boyscout](./skills/engineering/boyscout/SKILL.md)**: Leave the repo a little better than you found it. Looks at recent commits, PRs/MRs, issues and their comments (last 30 days by default) for patterns that keep going wrong or cases that were missed, and pins one down with a **deterministic test** (plus the minimal fix if it fails). Proposes first; implements only after you confirm.
- **[code-review](./skills/engineering/code-review/SKILL.md)**: Review the commits since a fixed point (commit, branch, tag, or merge-base) in two parallel passes: **standards** (the repo's coding docs plus Fowler's code smells) and **spec** (linked issues or a spec you give). Findings are reported separately, so neither masks the other.

## Credits

Inspired by [Matt Pocock's skills](https://github.com/mattpocock/skills).

## License

[MIT](./LICENSE)
