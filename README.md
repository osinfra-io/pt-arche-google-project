# Google Cloud Platform - Project OpenTofu Module

[![OpenTofu Tests](https://img.shields.io/github/actions/workflow/status/osinfra-io/pt-arche-google-project/test.yml?style=for-the-badge&logo=opentofu&color=FEDA15&label=OpenTofu%20Tests)](https://github.com/osinfra-io/pt-arche-google-project/actions/workflows/test.yml) [![Dependabot](https://img.shields.io/github/actions/workflow/status/osinfra-io/pt-arche-google-project/dependabot.yml?style=for-the-badge&logo=github&color=2088FF&label=Dependabot)](https://github.com/osinfra-io/pt-arche-google-project/actions/workflows/dependabot.yml) [![Datadog Security Enabled](https://img.shields.io/badge/Datadog%20Security-Enabled-632CA6?style=for-the-badge&logo=datadog)](https://app.datadoghq.com/security/code-security/repositories?repository_id=pt-arche-google-project)

## Repository Description

Reusable OpenTofu child module that creates a GCP project with CIS GCP Benchmark compliance controls, including audit log configuration (CIS 2.1), a KMS-encrypted log sink bucket (CIS 2.2), default network deletion (CIS 3.1), and OS Login enforcement (CIS 4.4). It configures a billing budget with threshold alerts and provisions Cloud Monitoring notification channels and alert policies for security events. GCP API enablement and project-level IAM are managed alongside the project lifecycle.

## 🔩 Usage

### Module interface

Consume the repository root with `source = "github.com/osinfra-io/pt-arche-google-project?ref=<commit_sha>"`. See [`variables.tofu`](variables.tofu) and [`outputs.tofu`](outputs.tofu).

The module creates the project without a default network, enables Cloud KMS and Logging plus requested services, configures full audit logging, a CMEK-protected 30-day log bucket and sink, CIS security metrics/alerts, OS Login, and a monthly billing budget. Project deletion defaults to `PREVENT`, log-bucket locking defaults to enabled, and randomized globally unique project IDs default to enabled. The default budget is only USD 5 and notification addresses default to osinfra.io aliases, so consumers outside that context must override them. Locked log buckets cannot be unlocked, API enablement can activate billable services, and KMS/log retention/monitoring generate ongoing costs.

> [!TIP]
> You can check the [tests/fixtures](tests/fixtures) directory for example configurations. These fixtures set up the system for testing by providing all the necessary initial code, thus creating good examples on which to base your configurations.

### Project Names

Project names include a prefix, a description as well as
an environment, for example:

```none
team-example-tf2a-sb
```

> [!NOTE]
> The `tf2a` is a hex output from the random resource. We do not want to duplicate project IDs because project IDs are globally unique. Also, when you delete a project, it goes into a pending deletion state for 30 days, where you can't reuse the project ID. If you want to exclude this from your project name, you can use the variable: `random_project_id = false`

## 🛠️ Tools

- [osinfra-pre-commit-hooks](https://github.com/osinfra-io/pt-techne-pre-commit-hooks)
- [pre-commit](https://github.com/pre-commit/pre-commit)

## 📋 Skills and Knowledge

Links to documentation and other resources required to develop and iterate in this repository successfully.

- [apis](https://cloud.google.com/apis/docs/overview)
- [audit logs](https://cloud.google.com/logging/docs/audit)
- [billing budgets](https://cloud.google.com/billing/docs/how-to/budgets)
- [kms](https://cloud.google.com/kms/docs)
- [logging metrics](https://cloud.google.com/logging/docs/logs-based-metrics)
- [logging routing](https://cloud.google.com/logging/docs/routing/overview)
- [monitoring alerts](https://cloud.google.com/monitoring/alerts)
- [project](https://cloud.google.com/resource-manager/docs/creating-managing-projects)

## 🔍 Tests

All tests are [mocked](https://opentofu.org/docs/cli/commands/test/#the-mock_provider-blocks) allowing us to test the module without creating infrastructure or requiring credentials. The trade-offs are acceptable in favor of speed and simplicity. In an OpenTofu test, a mocked provider or resource will generate fake data for all computed attributes that would normally be provided by the underlying provider APIs.

```none
tofu init
```

```none
tofu test
```

## 📦 Release

To release a new version, simply push a new tag to the repository. The tag should be in the format `vX.Y.Z` where `X`, `Y`, and `Z` are integers.

```none
git tag vX.Y.Z
git push origin vX.Y.Z
```
