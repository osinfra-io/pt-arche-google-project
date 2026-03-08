# Arche Team Instructions

## Repository Overview

These repositories are reusable OpenTofu child modules consumed by the corpus, logos, and pneuma platform repos. Each module encapsulates a set of GCP or Kubernetes resources for consistent reuse across the platform.

**Module structure patterns:**

- **Root module** — core resources at the repository root (`main.tofu`, `variables.tofu`, `outputs.tofu`, `locals.tofu`)
- **Sub-modules** — regional or functional sub-modules in subdirectories (e.g., `regional/`, `dns/`)
- **`shared/helpers.tofu`** — invokes `pt-arche-core-helpers` when present; provides environment detection, labels, and project naming

## GitHub Actions

- **Tests** (`test.yml`): runs `tofu test` on pull requests using `osinfra-io/pt-techne-opentofu-workflows`. Tests use mocked providers — no real infrastructure or credentials needed, so tests can be run locally.
- **Releases** (`release.yml`): triggered when a version tag (`v*.*.*`) is pushed; generates release notes automatically.

### Creating Releases

```bash
gh release create <tag>
```

After tagging, bump the module `ref` (commit SHA + version comment) in any consumer repos (corpus, logos, pneuma) to the new commit SHA.

## Repository Practices

- For detailed OpenTofu conventions (file structure, module pinning, resource patterns), refer to `.github/skills/opentofu.md`.
- The `team.instructions.md` file in `.github/instructions/` is maintained in `pt-arche-ai-context` and must be kept identical across all arche child module repositories. When making changes, propagate to all repos.
