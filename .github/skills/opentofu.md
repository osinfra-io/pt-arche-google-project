# OpenTofu

Specialized guidance for OpenTofu (Terraform) infrastructure-as-code workflows.

## File Structure & Organization

### Standard Files

- `main.tofu` - Resource and module declarations
- `data.tofu` - Data source definitions
- `locals.tofu` - Complex data transformations
- `variables.tofu` - Input variables with validation
- `outputs.tofu` - Output values
- `providers.tofu` - Provider configurations
- `helpers.tofu` - Present in any module directory that consumes `pt-arche-core-helpers`; provides environment detection, labels, team data, and project naming — check here before hardcoding any of those values

### File Headers

Every `.tofu` file begins with a comment block naming its purpose and linking to the OpenTofu docs:

```hcl
# Output Values
# https://opentofu.org/docs/language/values/outputs
```

Use the appropriate doc URL for each file type:
- Variables: `https://opentofu.org/docs/language/values/variables`
- Outputs: `https://opentofu.org/docs/language/values/outputs`
- Locals: `https://opentofu.org/docs/language/values/locals`

### Sub-Module Structure

Child module repositories may contain sub-modules in subdirectories:

- **`regional/`** - Regional resource sub-modules (e.g., resources scoped to a GCP region)
- **`dns/`**, **`nat/`**, etc. - Functional sub-modules
- **`shared/helpers.tofu`** - Top-level helpers invocation; sub-modules each have their own `helpers.tofu` in their directory

Each sub-module follows the same standard file conventions as the root module.

### Alphabetical Ordering Rules

- **Variables, outputs, locals, tfvars**: Strict alphabetical order
- **Resources/data sources**: Alphabetically by resource type
- **All arguments**: Alphabetically ordered at every nesting level
- **Meta-arguments first**: `count`, `depends_on`, `for_each`, `lifecycle`, `provider` (alphabetically among themselves)

### Formatting

- **Lists/Maps**: Empty newline before and after (unless first/last argument)
- **Functions**: Single-line for simple calls; multi-line for complex nested functions
- **Indentation**: 2 spaces (enforced by `tofu fmt`)

## Variables

Every variable must have `description` and `type`. Use `sensitive = true` for secrets. Add a `validation` block when the value must match a known pattern:

```hcl
# Input Variables
# https://opentofu.org/docs/language/values/variables

variable "repository" {
  description = "The repository name containing only lowercase alphanumeric characters or hyphens"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.repository))
    error_message = "The repository name must consist entirely of lowercase alphanumeric characters or hyphens"
  }
}

variable "token" {
  description = "The API token"
  type        = string
  sensitive   = true
}
```

## Outputs

Name outputs after the resource attribute they expose (`name`, `self_link`, `id`, `email`). Every output must have a `description`:

```hcl
# Output Values
# https://opentofu.org/docs/language/values/outputs

output "id" {
  description = "The project ID"
  value       = google_project.this.project_id
}

output "self_link" {
  description = "The URI of the created resource"
  value       = google_compute_network.this.self_link
}
```

For map outputs derived from `for_each` resources, expose the full map keyed the same way:

```hcl
output "emails" {
  description = "The email addresses of the service accounts"
  value       = { for k, v in google_service_account.this : k => v.email }
}
```

## Resource Patterns

### Meta-Arguments Priority

```hcl
resource "example" "this" {
  depends_on = [example.dependency]
  for_each   = local.items

  description = each.value.description
  name        = each.key
}
```

### Lifecycle Protection

Use `prevent_destroy = true` for resources that would cause significant disruption if accidentally destroyed. Use `ignore_changes` for fields managed externally:

```hcl
lifecycle {
  ignore_changes  = [attribute]
  prevent_destroy = true
}
```

### Conditional Resource Creation

**OpenTofu v1.11+ introduced the `enabled` meta-argument for cleaner conditional resource creation.**

**Prefer `enabled` over `count` for conditional resources:**

```hcl
# Modern approach (OpenTofu v1.11+)
resource "example" "conditional" {
  lifecycle {
    enabled = local.should_create
  }

  # Access directly without [0] indexing
  name = "example"
}

# Legacy approach (avoid)
resource "example" "conditional" {
  count = local.should_create ? 1 : 0

  # Requires array indexing [0]
  name = "example"
}
```

**Benefits of `enabled`:**

- Direct resource access (no `[0]` indexing)
- Proper null state handling when disabled
- Cleaner syntax and intent
- Works with complex boolean conditions

## Helpers Module

Some child modules consume `pt-arche-core-helpers` via `helpers.tofu` in each module directory that needs it. This provides environment detection, labels, team data, and project naming — check here before hardcoding any of those values.

- Always pin `source` to a commit SHA — never use a branch or semver tag
- The SHA must be followed by a version comment on the same line: `?ref=<sha>  # v1.2.3`

```hcl
# Core Child Module Helpers (osinfra.io)
# https://github.com/osinfra-io/pt-arche-core-helpers

module "helpers" {
  source = "github.com/osinfra-io/pt-arche-core-helpers//child?ref=<commit_sha>"  # v1.2.3
}
```

Access outputs as `module.helpers.<output>`:

- `module.helpers.env` - short form (`sb`, `np`, `prod`)
- `module.helpers.environment` - long form (`sandbox`, `non-production`, `production`)
- `module.helpers.labels` - standard label map to apply to resources

## Data Transformations

### Flattening Nested Structures

```hcl
locals {
  flat_items = flatten([
    for parent_key, parent in var.nested_structure : [
      for child_key, child_value in parent.children : {
        attributes = child_value
        child_id   = child_key
        key        = "${parent_key}-${child_key}"
        parent_id  = parent_key
      }
    ]
  ])
}
```

### String Transformation

```hcl
locals {
  normalized_values = {
    for value in local.input_values :
    value => replace(replace(value, "special_char", "replacement"), "pattern", "substitute")
  }
}
```

### Deduplication

```hcl
locals {
  non_overlapping = setsubtract(
    local.all_items,
    local.excluded_items
  )

  unique_items = distinct(flatten([
    for group in var.groups : group.items
  ]))
}
```

## Validation & Testing

### Pre-Commit Hooks

- `tofu fmt` - Auto-formats files
- `tofu validate` - Validates configuration syntax
- `tofu test` - Runs module tests in `tests/*.tftest.hcl`
- `check-yaml` - YAML syntax validation
- `trailing-whitespace` - Removes trailing whitespace
- `end-of-file-fixer` - Ensures files end with newline

### Module Tests

Tests live in `tests/` as `.tftest.hcl` files and are executed via `tofu test` in the `test.yml` GitHub Actions workflow on pull requests.

### Plugin Cache (Performance)

```bash
mkdir -p $HOME/.opentofu.d/plugin-cache
export TF_PLUGIN_CACHE_DIR=$HOME/.opentofu.d/plugin-cache
```

## References

- [OpenTofu Documentation](https://opentofu.org/docs/)
