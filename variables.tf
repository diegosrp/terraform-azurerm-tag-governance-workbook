variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
  default     = "rg-workbook"
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
  default     = "australiaeast"
}

variable "workbook_display_name" {
  description = "Display name for the Azure Workbook."
  type        = string
  default     = "Azure Tag Governance Workbook"
}

variable "mandatory_tags" {
  description = <<-EOT
    List of tag keys the workbook monitors for compliance.
    Azure tag names are case-insensitive for operations; this module validates
    keys case-insensitively to avoid duplicates like Owner/owner.
    To add a tag:    append a new string to the list.
    To remove a tag: delete the corresponding string.
    To update a tag: change the string value.

    Example:
      mandatory_tags = ["env", "app", "costcenter", "owner"]
  EOT
  type        = list(string)
  default = [
    "env",
    "app",
    "costcenter",
    "businessunit",
    "criticality",
    "opsteam"
  ]

  validation {
    condition     = length(var.mandatory_tags) > 0 && alltrue([for t in var.mandatory_tags : trimspace(t) != ""])
    error_message = "mandatory_tags must contain at least one non-empty tag key."
  }

  validation {
    condition     = length(distinct([for t in var.mandatory_tags : lower(trimspace(t))])) == length(var.mandatory_tags)
    error_message = "mandatory_tags must not contain duplicate tag keys (case-insensitive)."
  }

  validation {
    condition = alltrue([
      for t in var.mandatory_tags :
      length(trimspace(t)) <= 512 && length(regexall("[<>%&\\\\?/]", trimspace(t))) == 0
    ])
    error_message = "Each mandatory tag key must be <= 512 characters and must not contain: <, >, %, &, \\, ?, /."
  }
}

variable "excluded_management_groups" {
  description = <<-EOT
    Optional list of management group names to exclude from workbook queries.
    Use the management group name/ID segment (for example, mg-sandbox), not the
    display name and not the full Azure resource ID.
    Useful when you want to ignore sandbox or non-governed scopes.

    Example:
      excluded_management_groups = ["mg-sandbox", "landingzone-dev"]
  EOT
  type        = list(string)
  default     = []

  validation {
    condition = length([
      for mg in var.excluded_management_groups : trimspace(mg)
      if trimspace(mg) != ""
    ]) == length(var.excluded_management_groups)
    error_message = "excluded_management_groups must not contain empty names."
  }

  validation {
    condition = length(distinct([
      for mg in var.excluded_management_groups : lower(trimspace(mg))
    ])) == length(var.excluded_management_groups)
    error_message = "excluded_management_groups must not contain duplicates (case-insensitive)."
  }
}

variable "caf_tag_catalog" {
  description = "Official CAF tag examples and categories used to drive Guide documentation."
  type = map(object({
    category       = string
    purpose        = string
    example_values = list(string)
  }))
  default = {
    app = {
      category       = "Functional"
      purpose        = "Application or workload identifier."
      example_values = ["catalogsearch1", "training", "webapp"]
    }
    tier = {
      category       = "Functional"
      purpose        = "Technical tier/layer of the workload."
      example_values = ["web", "api", "data"]
    }
    webserver = {
      category       = "Functional"
      purpose        = "Web server technology in use."
      example_values = ["apache", "nginx", "iis"]
    }
    env = {
      category       = "Functional"
      purpose        = "Deployment environment."
      example_values = ["prod", "staging", "dev"]
    }
    region = {
      category       = "Functional"
      purpose        = "Region context used for operational and cost views."
      example_values = ["eastus", "uksouth"]
    }
    repo = {
      category       = "Functional"
      purpose        = "Source repository reference for the workload."
      example_values = ["https://github.com/org/repo"]
    }
    criticality = {
      category       = "Classification"
      purpose        = "Business criticality and incident priority context."
      example_values = ["mission-critical", "medium", "low"]
    }
    confidentiality = {
      category       = "Classification"
      purpose        = "Data confidentiality/sensitivity level."
      example_values = ["private", "internal", "public"]
    }
    sla = {
      category       = "Classification"
      purpose        = "Service level objective commitment."
      example_values = ["24hours"]
    }
    department = {
      category       = "Accounting"
      purpose        = "Department for cost attribution."
      example_values = ["finance", "sales", "engineering"]
    }
    program = {
      category       = "Accounting"
      purpose        = "Program or initiative for spend tracking."
      example_values = ["business-initiative", "modernization"]
    }
    businesscenter = {
      category       = "Accounting"
      purpose        = "Business center/geography for accounting segmentation."
      example_values = ["northamerica", "anz", "emea"]
    }
    budget = {
      category       = "Accounting"
      purpose        = "Budget allocation reference."
      example_values = ["$200,000"]
    }
    costcenter = {
      category       = "Accounting"
      purpose        = "Cost center code for chargeback/showback."
      example_values = ["55332"]
    }
    businessprocess = {
      category       = "Purpose"
      purpose        = "Business process supported by the workload."
      example_values = ["support", "billing", "claims"]
    }
    businessimpact = {
      category       = "Purpose"
      purpose        = "Impact to business operations if unavailable."
      example_values = ["high", "moderate", "low"]
    }
    revenueimpact = {
      category       = "Purpose"
      purpose        = "Impact on revenue if service degrades/fails."
      example_values = ["high", "medium", "low"]
    }
    businessunit = {
      category       = "Ownership"
      purpose        = "Owning business unit."
      example_values = ["finance", "marketing", "product xyz", "corp", "shared"]
    }
    opsteam = {
      category       = "Ownership"
      purpose        = "Operations team accountable for day-to-day management."
      example_values = ["central it", "cloud operations", "controlcharts team", "msp-contoso"]
    }
  }
}

variable "custom_tag_catalog" {
  description = "Optional catalog of custom tags that are outside the CAF baseline. Add entries for any tag included in mandatory_tags that is not defined in caf_tag_catalog. Keys are validated case-insensitively to mirror Azure tag-name behavior and avoid Owner/owner collisions."
  type = map(object({
    category       = string
    purpose        = string
    example_values = list(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for tag_key in keys(var.custom_tag_catalog) :
      trimspace(tag_key) != "" &&
      length(trimspace(tag_key)) <= 512 &&
      length(regexall("[<>%&\\\\?/]", trimspace(tag_key))) == 0
    ])
    error_message = "custom_tag_catalog keys must be non-empty, <= 512 characters, and must not contain: <, >, %, &, \\, ?, /."
  }

  validation {
    condition = length(distinct([
      for tag_key in keys(var.custom_tag_catalog) : lower(trimspace(tag_key))
    ])) == length(keys(var.custom_tag_catalog))
    error_message = "custom_tag_catalog must not contain duplicate keys when compared case-insensitively (for example, Owner and owner)."
  }

  validation {
    condition = length(setintersection(
      toset([for tag_key in keys(var.custom_tag_catalog) : lower(trimspace(tag_key))]),
      toset([for tag_key in keys(var.caf_tag_catalog) : lower(trimspace(tag_key))])
    )) == 0
    error_message = "custom_tag_catalog must not redefine tags already present in caf_tag_catalog (case-insensitive)."
  }
}

variable "tags" {
  description = <<-EOT
    Tags to apply to all resources.
    Azure tag names are case-insensitive; Azure tag values are case-sensitive.
    This module enforces case-insensitive uniqueness for tag keys and preserves
    tag values exactly as provided.
    To add a tag:    add a new key/value pair below.
    To remove a tag: delete the corresponding line.
    To update a tag: change the value.

    Example:
      tags = {
        project      = "my-project"
        env          = "prod"
        costcenter   = "900-000-000"
      }
  EOT
  type        = map(string)
  default = {
    project      = "workbook-tag-governance"
    env          = "prod"
    app          = "catalogsearch1"
    costcenter   = "55332"
    businessunit = "finance"
    criticality  = "mission-critical"
    opsteam      = "cloud operations"
  }

  validation {
    condition     = length(var.tags) <= 50
    error_message = "Azure supports a maximum of 50 tag name-value pairs per resource, resource group, or subscription."
  }

  validation {
    condition = length(distinct([
      for k in keys(var.tags) : lower(trimspace(k))
    ])) == length(keys(var.tags))
    error_message = "tags keys must be unique (case-insensitive)."
  }

  validation {
    condition = alltrue([
      for k in keys(var.tags) :
      trimspace(k) != "" &&
      length(trimspace(k)) <= 512 &&
      length(regexall("[<>%&\\\\?/]", trimspace(k))) == 0
    ])
    error_message = "Each tags key must be non-empty, <= 512 characters, and must not contain: <, >, %, &, \\, ?, /."
  }

  validation {
    condition = alltrue([
      for v in values(var.tags) :
      length(v) <= 256
    ])
    error_message = "Each tags value must be <= 256 characters."
  }
}
