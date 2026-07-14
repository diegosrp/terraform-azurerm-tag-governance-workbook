# Custom Tag Catalog Example

Deploys the workbook with additional custom tag metadata to extend the default catalog.

## Why use this example

Use this example when you need tags that are outside the CAF baseline and want to create and maintain a custom catalog.
It is the right option when your governance requirements go beyond the default Microsoft CAF tag set.

## What this example shows

- How to use `custom_tag_catalog`.
- How to keep `mandatory_tags` aligned with your governance model.
- How to document non-CAF tags in workbook guidance.

## Terraform configuration

```hcl
# Custom Tag Catalog Example
# This example shows how to publish the workbook with additional monitored tags and matching catalog metadata.

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

  # ─── Custom Tags Catalog (non-CAF, used by this workbook) ───────────────────
  custom_tag_catalog = {
    owner = {
      category       = "Ownership+"
      purpose        = "Named individual owner for fast escalation."
      example_values = ["jane.doe"]
    }
    owneremail = {
      category       = "Ownership+"
      purpose        = "Distribution list or owner email for notifications."
      example_values = ["platform-team@contoso.com"]
    }
    managedby = {
      category       = "Operations"
      purpose        = "Managing team or platform identifier."
      example_values = ["platform-team", "terraform", "aks-ops"]
    }
    lifecycle = {
      category       = "Lifecycle"
      purpose        = "Expected lifecycle stage."
      example_values = ["temporary", "permanent", "sunset"]
    }
    backup = {
      category       = "Resilience"
      purpose        = "Backup requirement indicator."
      example_values = ["required", "not-required"]
    }
    drtier = {
      category       = "Resilience"
      purpose        = "Disaster recovery tier/target posture."
      example_values = ["tier-0", "tier-1", "tier-2"]
    }
    dataresidency = {
      category       = "Compliance+"
      purpose        = "Data residency constraint for legal/regulatory scope."
      example_values = ["au", "eu", "us"]
    }
    expirationdate = {
      category       = "Lifecycle"
      purpose        = "Review/decommission date for temporary workloads."
      example_values = ["31-12-2027"]
    }
    patchwindow = {
      category       = "Operations"
      purpose        = "Maintenance/patch window coordination."
      example_values = ["sun-0200-aest", "sat-2300-utc"]
    }
  }

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
| custom_tag_catalog | owner/owneremail/managedby/lifecycle/backup/drtier/dataresidency/expirationdate/patchwindow |
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
