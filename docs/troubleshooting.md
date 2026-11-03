# Troubleshooting scenarios — analysis only, not observed incidents

## A. Service principal authenticates but blob upload returns AuthorizationPermissionMismatch / 403
- **Hypotheses:** missing Storage Blob Data Contributor role, assignment scoped to wrong container, RBAC propagation delay, inherited deny assignment, wrong SP identity, or wrong auth mode.
- **Investigate:** `az account show -o json`, `az role assignment list --assignee <sp-object-id> --all -o table`, `az storage blob list --account-name <account> --container-name reports --auth-mode login -o table`; review Storage diagnostic logs and request ID, role scope, and token audience.
- **Root cause:** compare active principal object ID, role and scope, and response code. Azure CLI subscription discovery may be limited for data-only identities; do not mistake this for a blob authorization result.
- **Fix:** apply a container-scoped Storage Blob Data Contributor role via Terraform, wait for propagation, renew token, retest upload/list/download.
- **Prevention:** automated permission tests, short-lived credentials, role review, avoid account keys.

## B. Azure Reader assigned; blob download fails
- **Hypotheses:** Reader is a management-plane role and does not grant blob content read through Entra data-plane authentication.
- **Investigate:** inspect `az role assignment list --assignee <sp-object-id> --all -o table` and verify storage request uses `--auth-mode login`; compare Reader with Storage Blob Data Reader and Contributor built-in roles.
- **Fix:** for read-only jobs use container-scoped Storage Blob Data Reader; for this upload-and-download app use container-scoped Storage Blob Data Contributor.
- **Prevention:** document control-plane vs data-plane privileges; least-privilege role catalog and integration tests.

## C. Suggestion to grant subscription Owner
- **Risk:** unnecessary management rights across unrelated resources, ability to alter access, high blast radius if credentials leak.
- **Investigate:** determine exact failing operation, identity, scope, and whether error is authentication or authorization.
- **Fix:** deny subscription Owner request; assign only required container-scoped data role and keep provisioning permissions separate.
- **Prevention:** approval workflows, policy-as-code, audit logs, and periodic access reviews.

## D. Secret expired
- **Hypotheses:** credential expiration, revoked secret, wrong tenant, clock skew, changed app permissions.
- **Investigate:** Azure CLI sign-in error code and Entra sign-in logs, application credential expiry metadata; do not print secret values.
- **Fix:** securely rotate credential, update secret store, verify authentication and blob access. Prefer managed identity or federation where available.
- **Prevention:** expiration alerts, automated rotation, vault-backed storage, avoid long-lived secrets.
