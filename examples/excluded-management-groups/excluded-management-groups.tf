# Excluded Management Groups Example
# This example shows how to ignore sandbox/lab management groups from workbook queries.

## Example root configuration
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.32.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

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
  # Use the management group ID (for example, mg-sandbox), not the display
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
