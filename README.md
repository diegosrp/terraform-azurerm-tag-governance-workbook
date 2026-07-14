# terraform-azurerm-tag-governance-workbook

Azure Monitor Workbook module for Azure tag governance across Management Groups and Subscriptions using Azure Resource Graph.

CAF-aligned by default, extensible for custom tags.

This repository contains a reusable Terraform module for Azure tag governance. The examples in `examples/` show how to consume the module from your own root configuration.

## How it works

All queries run through Azure Resource Graph, so the workbook evaluates the current tag state directly from Azure resources. That means results are real-time: fix a tag, refresh the page, and the workbook updates.

The workbook includes:

- A generated Guide tab that explains the monitored tags, mandatory tag coverage, and custom catalog entries.
- A Summary tab with KPI tiles, Tag Compliance views, Mandatory Tag Coverage, and subscription breakdowns.
- An Inventory tab with non-compliant resource group and resource-level drill-down tables.

## Tag case behavior (Azure-aligned)

Per Microsoft Learn:

- Tag names (keys) are case-insensitive for operations.
- Tag values are case-sensitive.

This module mirrors that behavior by:

- Validating key uniqueness case-insensitively in `mandatory_tags`, `custom_tag_catalog`, and `tags`.
- Rejecting key collisions such as `Owner` and `owner`.
- Preserving tag values as provided (no lowercasing/normalization of values).

Reference: [Use tags to organize your Azure resources and management hierarchy](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources)

## Repository Tree

```text
.
├── .gitignore
├── LICENSE
├── README.md
├── main.tf
├── locals.tf
├── variables.tf
├── outputs.tf
├── templates/
│   ├── workbook-tag-governance.json.tpl
│   └── queries/
│       ├── param-mg.kql
│       ├── param-sub.kql
│       ├── kpi-evaluated.kql
│       ├── kpi-mandatory-tags.kql.tpl
│       ├── kpi-compliance-pct.kql.tpl
│       ├── kpi-noncompliance-pct.kql.tpl
│       ├── kpi-compliant.kql.tpl
│       ├── kpi-noncompliant.kql.tpl
│       ├── chart-compliance-summary.kql.tpl
│       ├── chart-tag-coverage.kql.tpl
│       ├── table-compliance-by-subscription.kql.tpl
│       ├── table-compliance-by-resource-type.kql.tpl
│       ├── piechart-rg-compliance.kql.tpl
│       ├── piechart-resource-compliance.kql.tpl
│       ├── table-noncompliant-rg.kql.tpl
│       └── table-noncompliant-resources.kql.tpl
├── examples/
│   ├── README.md
│   ├── basic/
│   │   ├── basic.tf
│   │   └── README.md
│   ├── custom/
│   │   ├── custom-tag-catalog.tf
│   │   └── README.md
│   └── excluded-management-groups/
│       ├── excluded-management-groups.tf
│       └── README.md
└── images/
    ├── workbook-guide.png
    ├── workbook-summary.png
    └── workbook-inventory.png
```

## Workbook

### Guide

![Azure Tag Governance - Guide](https://raw.githubusercontent.com/diegosrp/terraform-azurerm-tag-governance-workbook/main/images/workbook-guide.png)

### Summary Tab

![Azure Tag Governance - Summary](https://raw.githubusercontent.com/diegosrp/terraform-azurerm-tag-governance-workbook/main/images/workbook-summary.png)

### Inventory Tab

![Azure Tag Governance - Inventory](https://raw.githubusercontent.com/diegosrp/terraform-azurerm-tag-governance-workbook/main/images/workbook-inventory.png)

## Usage

Use the module from a root configuration and reference it from the Terraform Registry.

```hcl
module "tag_governance_workbook" {
  source  = "diegosrp/tag-governance-workbook/azurerm"
  version = "1.0.0"

  resource_group_name   = "rg-workbook"
  location              = "australiaeast"
  workbook_display_name = "Azure Tag Governance Workbook"
  mandatory_tags        = [
    "env", 
    "app", 
    "costcenter", 
    "businessunit", 
    "criticality", 
    "opsteam"
    ]

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

## Examples

- [`examples/basic/`](examples/basic/) - Basic usage with the default CAF catalog and baseline mandatory tags.
- [`examples/custom/`](examples/custom/) - Extended usage with custom tag metadata beyond the CAF baseline.
- [`examples/excluded-management-groups/`](examples/excluded-management-groups/) - Example excluding sandbox/lab management groups from workbook scope.

## Deployment

1. Review the example that matches your scenario.
2. Set your inputs and version constraint in the consuming root module.
3. Run Terraform from that root configuration.

```bash
terraform init
terraform plan
terraform apply
```

## Requirements

| Component | Version |
| --- | --- |
| Terraform CLI | >= 1.9.0 |
| azurerm | >= 4.32.0 |
| random | >= 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
| --- | --- | --- | --- | --- |
| `resource_group_name` | Name of the resource group. | `string` | `"rg-workbook"` | no |
| `location` | Azure region for all resources. | `string` | `"australiaeast"` | no |
| `workbook_display_name` | Display name for the Azure Workbook. | `string` | `"Azure Tag Governance Workbook"` | no |
| `mandatory_tags` | List of tag keys the workbook monitors for compliance. | `list(string)` | `["env", "app", "costcenter", "businessunit", "criticality", "opsteam"]` | no |
| `excluded_management_groups` | Optional list of management group names to exclude from workbook queries and parameter options. Use the management group name/ID segment (for example, `mg-sandbox`), not the display name and not the full Azure resource ID. | `list(string)` | `[]` | no |
| `caf_tag_catalog` | Official CAF tag examples and categories used to drive Guide documentation. | `map(object({ category = string, purpose = string, example_values = list(string) }))` | CAF baseline catalog in code | no |
| `custom_tag_catalog` | Custom tags catalog used by this workbook and documented in the examples. | `map(object({ category = string, purpose = string, example_values = list(string) }))` | `{}` | no |
| `tags` | Tags to apply to all resources. | `map(string)` | `{ project = "workbook-tag-governance", env = "prod", app = "catalogsearch1", costcenter = "55332", businessunit = "finance", criticality = "mission-critical", opsteam = "cloud operations" }` | no |

## Outputs

| Name | Description |
| --- | --- |
| `workbook_resource_id` | Resource ID of the Azure Workbook. |

## What to fill in

- Fill `mandatory_tags` when you want a different compliance baseline.
- Fill `excluded_management_groups` when you want to ignore specific management groups by management group name (for example, `mg-sandbox`), not by display name.
- Fill `custom_tag_catalog` only for tags that are not in the CAF catalog but still appear in `mandatory_tags`.
- Fill `tags` if you want different resource group tags.
- Fill `resource_group_name`, `location`, and `workbook_display_name` only when the defaults do not match your naming or region.

## What to leave as default

- Leave `caf_tag_catalog` alone unless you need to extend the built-in CAF documentation catalog.
- Leave `custom_tag_catalog` as `{}` if you are only using the built-in CAF tags.
- Leave `mandatory_tags` as-is if the default six-tag baseline is enough.

## Authors

Module is created and maintained by [Diego Pauletto](https://github.com/diegosrp) with help from [these awesome contributors](https://github.com/diegosrp/terraform-azurerm-tag-governance-workbook/graphs/contributors).

## License

Apache 2.0 Licensed. See [LICENSE](https://github.com/diegosrp/terraform-azurerm-tag-governance-workbook/blob/main/LICENSE) for full details.
