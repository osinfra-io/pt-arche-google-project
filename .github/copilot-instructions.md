# GitHub Copilot Repository Instructions

## Repository Overview

These repositories are reusable OpenTofu child modules consumed by platform team repositories. Each module encapsulates resources for consistent reuse across the platform.

**Common module structure patterns:**

- **Root module** - Core module at the repository root (`main.tofu`, `variables.tofu`, `outputs.tofu`, `locals.tofu`)
- **Sub-modules** - Regional or functional sub-modules in subdirectories (e.g., `regional/`, `dns/`)
- **`shared/helpers.tofu`** - Invokes `pt-arche-core-helpers` when present; provides environment detection, labels, and project naming

## Coding Standards

- Always run pre-commit validation after making any changes: `pre-commit run -a`.
- Document complex logic with comments.

### Automated Pre-Commit Execution

**CRITICAL: Copilot must automatically run pre-commit hooks after making ANY changes to OpenTofu files** (`.tofu`, `.tfvars`, or any file in an OpenTofu directory).

This ensures:
- Hooks are updated to latest versions with pinned commit hashes
- Code is properly formatted
- Documentation is up-to-date
- All validations succeed

**Workflow:**
1. Make OpenTofu code changes
2. Run `pre-commit autoupdate --freeze` to update hooks and pin to commit hashes
3. Run `pre-commit run -a` to execute all hooks
4. Report any errors or fixes applied
5. Do not wait to be asked - this is automatic behavior

## Code Quality Principles

- **Keep it simple** - Favor straightforward solutions over clever ones. If there are multiple ways to solve a problem, choose the most obvious and maintainable approach.
- **Less is more** - Write only the code necessary to solve the problem at hand. Every line of code is a liability that must be maintained, tested, and understood.
- **Avoid over-engineering** - Don't add abstraction, flexibility, or complexity for hypothetical future needs. Solve today's problems today; refactor when actual requirements emerge.
- **Value clarity over brevity** - Longer, explicit code that's easy to understand is better than terse, "clever" code that saves a few lines but obscures intent.
- **Prefer explicit over implicit** - Make dependencies, transformations, and logic flows obvious. Magic behaviors and hidden assumptions create maintenance burden.
- **Write code for humans first** - Code is read far more often than it's written. Optimize for the next person who needs to understand and modify it.

## GitHub Actions

- Tests are run via `test.yml` on pull requests using the `osinfra-io/pt-techne-opentofu-workflows` reusable called workflow.
- Releases are published via `release.yml` when a version tag (`v*.*.*`) is pushed.
- All GitHub Actions must use commit hashes instead of version tags for security and reproducibility.

### Creating Releases

Create a tag — the GitHub Actions release workflow does the rest (generates notes, publishes the release):

```bash
gh release create <tag>
```
- Bump the module ref in any consumer repos after the release is tagged

### Branching Workflow

Always `checkout main` and `git pull` before creating a new branch:

```bash
git checkout main && git pull && git checkout -b <branch-name>
```

### Commit Hash Guidelines

- **Use full 40-character SHA** - Never use short hashes; they can be ambiguous
- **Add version comment** - Include the tag/version as an inline comment for readability: `@<hash>  # v<version>`
- **Update deliberately** - When updating an action, update both the hash and the version comment
- **Verify hashes** - Ensure the commit hash matches the tagged version you intend to use

## Commit and PR Conventions

- **No Conventional Commits** — do not prefix messages with `feat:`, `fix:`, `chore:`, `refactor:`, etc.
- Write commit messages and PR titles in clear, natural language using sentence case.
- Keep titles concise but descriptive.
- Use GitHub labels (e.g., `enhancement`, `bug`, `refactor`, `docs`) to categorize PRs instead of encoding type in the title.
- PR descriptions should explain what changed, why it changed, and any impact or migration considerations.

✅ **Good:** `Improve metadata validation for GKE handler`
❌ **Avoid:** `feat: add metadata endpoint`

## Repository Practices

- Use symlinks for shared configuration files to avoid duplication.
- For OpenTofu-specific conventions (file structure, module pinning, resource patterns), refer to `.github/skills/opentofu.md`.

### Before Starting Any Task

Before making any changes, ensure all affected repositories are on `main` and in sync with `origin/main`:

```bash
git checkout main && git pull
```

- If a local branch already exists from a previous task, delete it before starting fresh
- After a PR is merged, pull `main` and delete the local branch to stay clean

### Workspace Workflow Patterns

- **Simultaneous multi-repo editing** - Apply standardization, updates, or patterns across all child module repos at once
- **Consistent changes** - Ensure configurations, workflows, or infrastructure patterns are aligned
- **Workspace-wide search and replace** - Use VS Code's multi-root capabilities to find and update patterns across repos
- **Parallel PR management** - Create and manage pull requests across multiple repositories for coordinated changes

**When performing bulk operations:**
- Verify changes apply correctly to each repository's unique structure

**IMPORTANT - Instruction File Synchronization:**

The `.github/copilot-instructions.md` file **MUST be identical across all child module repositories**. When making changes to this instructions file:
- Apply the same changes to **all child module repositories** in the current workspace
- Do not wait to be asked - automatically update all repos when modifying instructions
- Maintain consistency to ensure Copilot behavior is uniform across the platform

## References

- [Repository instructions documentation](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-custom-instructions)
