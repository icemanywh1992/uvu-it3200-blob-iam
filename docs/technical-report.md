# Technical Report — Cloud Identity and Access Management: Azure Blob Storage

**Course:** UVU IT 3200  
**Student identifier:** yeewi  
**Status:** Configuration prepared; no Azure subscription available, so deployment and live access tests remain incomplete.

## Executive summary
The scenario is an automated reporting service that uploads and downloads reports from Azure Blob Storage without a personal Azure account or shared storage keys. The proposed design provisions a resource group, storage account, private `reports` container, Entra application and service principal, and a narrowly scoped `Storage Blob Data Contributor` role. Terraform defines the infrastructure and access control. The role is initially disabled so authorization can be tested before and after assignment.

## Architecture
See [architecture.md](architecture.md). The service principal authenticates to Entra ID and obtains an access token. Azure Storage independently evaluates Azure RBAC for blob data operations. The runtime identity is separate from the provisioning identity. The role is scoped to the private container rather than the subscription.

## Infrastructure and identity
- **Resource group:** isolates the lab resources.
- **Storage account:** StorageV2, Standard LRS, TLS 1.2 minimum, HTTPS-only, public anonymous access disabled, shared-key authentication disabled.
- **Private container:** `reports`.
- **Application registration:** global application definition, including its client ID.
- **Service principal:** tenant-local security identity used for authorization and sign-in.
- **Authentication:** approved short-lived secret for classroom tests or federated credentials; Terraform does not create or store credentials.

## RBAC decision
`Reader` covers Azure management-plane read actions, not blob contents. `Storage Blob Data Reader` cannot upload. `Storage Blob Data Owner` is broader than needed. `Storage Blob Data Contributor` supports the application's required upload, list, and download operations. Terraform targets the container resource-manager ID. The SP must not receive Owner or subscription-wide Contributor. Check for inherited roles before treating the initial negative test as valid.

## Planned test results — not executed
| Test | Expected | Actual result |
|---|---|---|
| Service principal authentication | Success with valid credential | Not tested — no subscription |
| Read blobs before data role | Denied if no inherited access | Not tested |
| Upload blob after role assignment | Success after propagation | Not tested |
| List and download blobs | Success | Not tested |
| Access unrelated private container | Denied absent other grants | Not tested |

No screenshots of deployed resources, access-denied responses, or successful transfers exist yet. Do not submit hypothetical results as observed evidence.

## Troubleshooting
See [troubleshooting.md](troubleshooting.md). Scenario A addresses successful authentication with 403 data access denial; Scenario B explains why the Azure Reader role does not grant blob data access. Scenarios C and D address excessive permissions and expired credentials.

## Security analysis
Separate deployment and runtime identities, disable shared-key authentication, deny public anonymous blob access, use container-level RBAC, prefer managed identities or federation for production, rotate any temporary credential, audit access and avoid secrets in Terraform state or Git history. Public network access is currently enabled for lab simplicity; production should assess private endpoints, network controls, logging, and retention policies.

## Reflection and scale
The key distinction is that authentication proves identity while authorization grants specific operations. Infrastructure as Code makes role scopes reviewable and reproducible, but cannot replace live verification. For 500 applications, assign distinct workload identities, use reusable Terraform modules, enforce automated access tests, and monitor identity lifecycle and permissions centrally. The major current challenge is missing authorized Azure subscription access, not a verified storage or RBAC failure.

## Evidence checklist
- [ ] Terraform init/fmt/validate screenshot (only check when executed)
- [ ] Successful Terraform apply
- [ ] Azure storage account and private container
- [ ] Entra app/SP identifiers with secrets redacted
- [ ] Container-scoped role assignment
- [ ] Actual pre-RBAC access denial
- [ ] Actual upload, list, download and file comparison
- [ ] Actual denied unauthorized operation
- [ ] Terraform destroy and cleanup verification

## References
- [Microsoft: Authorize access to blobs with Microsoft Entra ID](https://learn.microsoft.com/en-us/azure/storage/blobs/authorize-access-azure-active-directory)
- [Microsoft: Assign Azure roles for blob data access](https://learn.microsoft.com/en-us/azure/storage/blobs/assign-azure-role-data-access)
- [Microsoft: Application objects and service principals](https://learn.microsoft.com/en-us/entra/identity-platform/app-objects-and-service-principals)
- [Microsoft: Azure RBAC overview](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview)
- [Terraform AzureRM storage account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
- [Terraform AzureRM role assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)

## AI assistance disclosure
ChatGPT assisted in drafting Terraform configuration, documentation, architecture, test procedures, and troubleshooting hypotheses. The student must independently validate commands, review security choices, and record actual cloud results when access becomes available. No live deployment or tests are claimed.
