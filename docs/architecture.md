# Architecture — identity and authorization flow

```mermaid
flowchart TB
    T[Terraform run by authorized provisioning identity] --> ARM[Azure Resource Manager]
    ARM --> RG[Resource group]
    RG --> ST[Storage account: HTTPS, no anonymous public access, shared key disabled]
    ST --> C[Private reports container]
    T --> E[Entra app registration and service principal]
    T --> R[Optional container-scoped Storage Blob Data Contributor role]
    R --> C
    APP[Automated reporting app / Azure CLI] -->|Service principal credentials| E
    E -->|Entra access token| APP
    APP -->|OAuth bearer token: blob upload/list/download| ST
    ST -->|Azure RBAC data-plane evaluation| R
    R -->|Authorized operations only| C
```

**Trust boundaries:** Entra authenticates the application; Azure Storage enforces data-plane authorization based on RBAC. The provisioning identity needs broader deployment permissions than the runtime service principal. Runtime access is scoped to one container. A managed identity or workload identity federation is preferable for production where supported.
