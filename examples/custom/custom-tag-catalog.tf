# Custom Tag Catalog Example
# This example shows how to publish the workbook with additional monitored tags and matching catalog metadata.

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
