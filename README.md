# UVU IT 3200 — Azure Blob Storage IAM Lab

**Status:** Terraform project prepared; cloud deployment and access tests **not performed** because the student's UVU Azure account has no accessible subscription.

## Architecture
See [docs/architecture.md](docs/architecture.md). Terraform defines a resource group, private Azure Storage container, Entra application/service principal, and an optional container-scoped `Storage Blob Data Contributor` role assignment. Shared-key authentication and anonymous public blob access are disabled. Service principal credentials are **not** created or stored by Terraform.

## Prerequisites
Terraform, Azure CLI, authorized Azure subscription, permission to create Entra applications/service principals and role assignments, and permission to provision Azure resources. These privileges are separate and may require administrator approval. Creating a storage container via ARM can also depend on provider/tenant policy.

## Reproduction (Windows CMD)
1. `cd terraform`
2. `copy terraform.tfvars.example terraform.tfvars` and edit the subscription ID and unique storage suffix. **Never commit `terraform.tfvars`.**
3. `terraform init -backend=false`
4. `terraform fmt -check` and `terraform validate`
5. When subscription access is approved: `az login`, `az account show -o table`, `terraform plan -out=tfplan`, review the plan, `terraform apply tfplan`.
6. Begin with `enable_blob_role = false` and verify the SP has no inherited blob data roles. Create a short-lived client secret through an approved secure process **outside Terraform** (or use federation), keep it out of terminal screenshots, source control, and Terraform state. Use `az login --service-principal --username <client-id> --password <secret> --tenant <tenant-id>` from a secured shell; avoid storing secrets in command history if possible. `az account set --subscription <subscription-id>` may fail for SPs without subscription-level Reader access; Azure CLI blob commands with explicit account and `--auth-mode login` may still work.
7. Run a pre-RBAC test using `az storage blob list --account-name <storage-account> --container-name reports --auth-mode login -o table`. Expect authorization denied **only if** the identity has no inherited data role. Capture sanitized evidence.
8. Set `enable_blob_role = true`, run `terraform plan` and `terraform apply`, and allow time for RBAC propagation. Refresh SP login/token.
9. Create a local sample file: `echo Sample reporting output> sample-report.txt`. Upload: `az storage blob upload --account-name <storage-account> --container-name reports --name sample-report.txt --file sample-report.txt --auth-mode login`. List: `az storage blob list --account-name <storage-account> --container-name reports --auth-mode login -o table`. Download: `az storage blob download --account-name <storage-account> --container-name reports --name sample-report.txt --file downloaded-report.txt --auth-mode login`. Compare: `fc sample-report.txt downloaded-report.txt`.
10. Negative test: attempt blob access in a separate private container with no granted role, if one is available, or an unauthorized management action. Do not assume a role denial until observed.
11. Re-authenticate as your authorized deployment identity and run `terraform destroy` after collecting evidence. Verify cleanup in the portal. Remove temporary secrets/credentials.

## Security and troubleshooting
See [docs/technical-report.md](docs/technical-report.md), [docs/troubleshooting.md](docs/troubleshooting.md), and [docs/ai-assistance.md](docs/ai-assistance.md). No client secrets, storage keys, state, or tokens belong in GitHub. Inspect Git history before submitting.

## Known limitations
The service principal may need additional tenant approval for registration and credentials. AzureRM provider schema and RBAC scope should be validated with the installed version. `terraform validate` cannot verify cloud permissions. This project is a starting implementation, not proof of deployment.
