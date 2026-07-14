# Excluded Management Groups Example

Deploys the workbook while excluding selected management groups from query scope.

## Why use this example

Use this example when one or more management groups follow different mandatory tag standards than the rest of your environment.
For example, sandbox management groups often have more relaxed tagging requirements, so excluding them avoids skewing global compliance views.

## What this example shows

- How to use `excluded_management_groups`.
- How to omit sandbox/lab management groups from inventory and parameters.

## Terraform configuration

```hcl
# Excluded Management Groups Example
# This example shows how to ignore sandbox/lab management groups from workbook queries.

# Example root configuration
module "tag_governance_workbook" {
  source  = "diegosrp/tag-governance-workbook/azurerm"
  version = "1.0.0"

  resource_group_name   = "rg-workbook"
  location              = "australiaeast"
  workbook_display_name = "Azure Tag Governance Workbook"

  # ─── Mandatory Tags (monitored by the workbook) ──────────────────────────────
  mandatory_tags = [
    "env",
    "app",
    "costcenter",
    "businessunit",
    "criticality",
    "opsteam"
  ]

  # ─── Management Groups Excluded from Scope ───────────────────────────────────
  # Any management group listed here is excluded from scope.
  # Use the management group ID (for example, mg-sandbox), not the display name
  # and not the full Azure resource ID.
  # Descendant subscriptions are also excluded from parameters and inventory queries.
  excluded_management_groups = [
    "mg-sandbox",
    "mg-lab"
  ]

  # ─── Tags ─────────────────────────────────────────────────────────────────────
  # Add, remove, or change any key/value pair here.
  # These tags will be applied to all resources created by this configuration.
  tags = {
    project      = "workbook-tag-governance"
    env          = "prod"
    app          = "catalogsearch1"
    costcenter   = "55332"
    businessunit = "finance"
    criticality  = "mission-critical"
    opsteam      = "cloud operations"
  }
}
```

## Requirements

| Name | Version |
| --- | --- |
| terraform | >= 1.9.0 |
| azurerm | >= 4.32.0 |
| random | >= 3.0.0 |

## Providers

| Name | Version |
| --- | --- |
| hashicorp/azurerm | >= 4.32.0 |
| hashicorp/random | >= 3.0.0 |

## Modules

| Name | Source | Version |
| --- | --- | --- |
| tag_governance_workbook | diegosrp/tag-governance-workbook/azurerm | 1.0.0 |

## Resources

This example root module does not define resources directly.

Resources are created inside the module:

- [random_uuid](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid)
- [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)
- [azurerm_application_insights_workbook](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights_workbook)

## Required inputs

None.

## Optional inputs

| Name | Value in this example |
| --- | --- |
| resource_group_name | rg-workbook |
| location | australiaeast |
| workbook_display_name | Azure Tag Governance Workbook |
| mandatory_tags | ["env", "app", "costcenter", "businessunit", "criticality", "opsteam"] |
| excluded_management_groups | ["mg-sandbox", "mg-lab"] |
| tags | project/env/app/costcenter/businessunit/criticality/opsteam |

## Outputs

This example root module does not define outputs.

Module output available:

- workbook_resource_id

## Usage

Run from this directory:

```bash
terraform init
terraform plan
terraform apply
```
