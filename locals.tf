locals {
  # Optional management groups to exclude from all workbook queries.
  mg_excluded_names_normalized = [
    for mg in var.excluded_management_groups : lower(trimspace(mg))
  ]

  mg_excluded_names_kql = [
    for mg in local.mg_excluded_names_normalized : format("'%s'", replace(mg, "'", "''"))
  ]

  # KQL-safe list used in expressions like: mgName in~ (${mg_excluded_list})
  # Uses a sentinel when empty so query syntax remains valid.
  kql_mg_excluded_list = (
    length(local.mg_excluded_names_kql) > 0
    ? join(", ", local.mg_excluded_names_kql)
    : "'__no_excluded_management_group__'"
  )

  kql_mg_exclusion_suffix = (
    length(local.mg_excluded_names_normalized) > 0
    ? format(
      " and tostring(mgParent.name) !in~ (%s)",
      local.kql_mg_excluded_list
    )
    : ""
  )

  guide_non_caf_tags_punctuated = (
    length(local.guide_non_caf_tags) > 0
    ? concat(
      [for i, tag in local.guide_non_caf_tags : format("`%s`", tag) if i < length(local.guide_non_caf_tags) - 1],
      [format("`%s.`", local.guide_non_caf_tags[length(local.guide_non_caf_tags) - 1])]
    )
    : []
  )

  guide_excluded_mgs_punctuated = (
    length(local.mg_excluded_names_normalized) > 0
    ? concat(
      [for i, mg in local.mg_excluded_names_normalized : format("`%s`", mg) if i < length(local.mg_excluded_names_normalized) - 1],
      [format("`%s.`", local.mg_excluded_names_normalized[length(local.mg_excluded_names_normalized) - 1])]
    )
    : ["`None.`"]
  )

  # Guide metadata derived from the built-in catalog.
  guide_caf_categories = join(", ", sort(distinct([
    for tag_key in sort(keys(var.caf_tag_catalog)) : var.caf_tag_catalog[tag_key].category
  ])))

  # Azure tag names are case-insensitive. Normalize keys to avoid lookup drift.
  caf_tag_catalog_normalized = {
    for tag_key, tag_meta in var.caf_tag_catalog :
    lower(trimspace(tag_key)) => tag_meta
  }

  custom_tag_catalog_normalized = {
    for tag_key, tag_meta in var.custom_tag_catalog :
    lower(trimspace(tag_key)) => tag_meta
  }

  mandatory_tags_normalized = [
    for tag in var.mandatory_tags : lower(trimspace(tag))
  ]

  # Active monitored tags resolved against built-in and custom catalogs.
  guide_active_tags = [
    for tag in local.mandatory_tags_normalized : {
      tag      = tag
      source   = contains(keys(local.caf_tag_catalog_normalized), tag) ? "CAF" : contains(keys(local.custom_tag_catalog_normalized), tag) ? "Custom" : "Custom"
      category = contains(keys(local.caf_tag_catalog_normalized), tag) ? local.caf_tag_catalog_normalized[tag].category : contains(keys(local.custom_tag_catalog_normalized), tag) ? local.custom_tag_catalog_normalized[tag].category : "N/A"
      purpose  = contains(keys(local.caf_tag_catalog_normalized), tag) ? local.caf_tag_catalog_normalized[tag].purpose : contains(keys(local.custom_tag_catalog_normalized), tag) ? local.custom_tag_catalog_normalized[tag].purpose : "Custom tag not cataloged yet."
    }
  ]

  guide_active_tags_by_tag = {
    for t in local.guide_active_tags : t.tag => t
  }
  guide_active_category_counts = {
    for c in distinct([for t in local.guide_active_tags : t.category]) :
    c => length([for t in local.guide_active_tags : t.tag if t.category == c])
  }
  guide_active_sort_keys = sort([
    for t in local.guide_active_tags : "${t.source == "CAF" ? "0" : "1"}|${lower(t.category)}|${format("%05d", 99999 - local.guide_active_category_counts[t.category])}|${lower(t.tag)}|${t.tag}"
  ])

  # Coverage metrics shown in the Guide tab.
  guide_non_caf_tags  = [for t in local.guide_active_tags : t.tag if t.source != "CAF"]
  guide_caf_count     = length([for t in local.guide_active_tags : t.tag if t.source == "CAF"])
  guide_non_caf_count = length(local.guide_non_caf_tags)
  guide_caf_active_categories = distinct([
    for t in local.guide_active_tags : t.category if t.source == "CAF"
  ])
  guide_caf_category_total = length(distinct([
    for tag_key in keys(var.caf_tag_catalog) : var.caf_tag_catalog[tag_key].category
  ]))
  guide_caf_category_count = length(local.guide_caf_active_categories)

  guide_caf_tag_coverage_pct = (
    length(local.mandatory_tags_normalized) > 0
    ? format("%.1f", 100 * local.guide_caf_count / length(local.mandatory_tags_normalized))
    : "0.0"
  )

  guide_caf_category_coverage_pct = (
    local.guide_caf_category_total > 0
    ? format("%.1f", 100 * local.guide_caf_category_count / local.guide_caf_category_total)
    : "0.0"
  )

  guide_active_rows = join("\n", [
    for sort_key in local.guide_active_sort_keys :
    format(
      "| `%s` | %s | %s | %s |",
      split("|", sort_key)[4],
      local.guide_active_tags_by_tag[split("|", sort_key)[4]].source,
      local.guide_active_tags_by_tag[split("|", sort_key)[4]].category,
      local.guide_active_tags_by_tag[split("|", sort_key)[4]].purpose
    )
  ])

  guide_caf_category_counts = {
    for c in distinct([for _, tag_meta in var.caf_tag_catalog : tag_meta.category]) :
    c => length([for _, tag_meta in var.caf_tag_catalog : 1 if tag_meta.category == c])
  }
  guide_caf_sorted_keys = sort([
    for tag_key, tag_meta in var.caf_tag_catalog : "${lower(tag_meta.category)}|${format("%05d", 99999 - local.guide_caf_category_counts[tag_meta.category])}|${lower(tag_key)}|${tag_key}"
  ])

  # Built-in and custom catalog markdown table rows.
  guide_caf_rows = join("\n", [
    for sort_key in local.guide_caf_sorted_keys :
    format(
      "| `%s` | %s | %s | %s |",
      split("|", sort_key)[3],
      var.caf_tag_catalog[split("|", sort_key)[3]].category,
      var.caf_tag_catalog[split("|", sort_key)[3]].purpose,
      join(", ", [for v in var.caf_tag_catalog[split("|", sort_key)[3]].example_values : format("`%s`", v)])
    )
  ])

  guide_custom_category_counts = {
    for c in distinct([for _, tag_meta in local.custom_tag_catalog_normalized : tag_meta.category]) :
    c => length([for _, tag_meta in local.custom_tag_catalog_normalized : 1 if tag_meta.category == c])
  }
  guide_custom_sorted_keys = sort([
    for tag_key, tag_meta in local.custom_tag_catalog_normalized : "${lower(tag_meta.category)}|${format("%05d", 99999 - local.guide_custom_category_counts[tag_meta.category])}|${lower(tag_key)}|${tag_key}"
  ])

  guide_custom_catalog_rows = join("\n", [
    for sort_key in local.guide_custom_sorted_keys :
    format(
      "| `%s` | %s | %s | %s |",
      split("|", sort_key)[3],
      local.custom_tag_catalog_normalized[split("|", sort_key)[3]].category,
      local.custom_tag_catalog_normalized[split("|", sort_key)[3]].purpose,
      join(", ", [for v in local.custom_tag_catalog_normalized[split("|", sort_key)[3]].example_values : format("`%s`", v)])
    )
  ])

  guide_non_caf_note = (
    local.guide_non_caf_count > 0
    ? format("**Custom Tags Monitored:** %s", join(", ", local.guide_non_caf_tags_punctuated))
    : "**Custom Tags Monitored:** `None.`"
  )

  guide_excluded_mg_note = (
    format("**Excluded Management Groups:** %s", join(", ", local.guide_excluded_mgs_punctuated))
  )

  guide_custom_catalog_section = (
    length(keys(var.custom_tag_catalog)) > 0
    ? <<-EOT

    ### Custom Tags Catalog
    Custom and operational tags used alongside CAF baseline.

    | Tag | Category | Purpose | Example Values |
    |---|---|---|---|
    ${local.guide_custom_catalog_rows}
    EOT
    : ""
  )

  # Full Guide markdown injected into the workbook template.
  guide_intro_markdown = <<-EOT
    # Azure Tag Governance Dashboard

    Designed to help governance and platform teams enforce consistent tagging standards across Azure environments. CAF-aligned by default, extensible for custom tags.  
    This page is auto-generated from Terraform inputs. Guide and queries stay synchronized automatically.

    ---

    ## What's Currently Monitored
    | Tag | Source | Category | Purpose |
    |---|---|---|---|
    ${local.guide_active_rows}

    **CAF Category Coverage:** ${local.guide_caf_category_coverage_pct}% (${local.guide_caf_category_count}/${local.guide_caf_category_total}) of CAF foundational categories are represented.  
    **Mandatory Tag Coverage:** ${local.guide_caf_tag_coverage_pct}% of monitored tags are official CAF tags.  
    **Custom Count:** ${local.guide_non_caf_count} of ${length(var.mandatory_tags)}.  
    ${local.guide_non_caf_note}  
    ${local.guide_excluded_mg_note}  

    ---

    ## Compliance Logic
    A resource is marked **Non-Compliant** when at least one tag in the table above is missing, empty, or whitespace-only.

    ---

    ## Available Tags to Monitor
    These are the official and recommended tags you can add to `mandatory_tags`.

    ### CAF Foundational Tags
    **Categories:** ${local.guide_caf_categories}.

    | Tag | Category | Purpose | Example Values |
    |---|---|---|---|
    ${local.guide_caf_rows}
  ${local.guide_custom_catalog_section}

    ---

    ## How to Adapt This Workbook

    ### Add a New Tag to Monitoring
    1. Open your root module configuration and find the `mandatory_tags = [...]` input in the module block.
    2. Add your tag key (e.g., `"owner"`).
    3. Run `terraform apply`.
    4. Reopen workbook; queries and Guide update automatically.

    ### Remove or Update Tags
    Same flow as above: edit `mandatory_tags`, apply, and refresh the workbook.

    ### Recommended Baseline (for most enterprises)
    `env`, `app`, `costcenter`, `businessunit`, `criticality`, `opsteam`

    ---

    ## How This Workbook Works
    - **Scope:** Management Group filtered (defaults to All / tenant-wide).
    - **Data source:** Azure Resource Graph (queries both individual Resources and Resource Groups).
    - **Audience:** Governance, Platform, FinOps, Security, and Operations teams.
    - **Sync:** Guide, KPIs, and Inventory queries all derive from `mandatory_tags` in Terraform, with no manual sync needed.

    ---

    ## References
    | Document | Link |
    |---|---|
    | CAF: Define your tagging strategy | [Define your tagging strategy](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging) |
    | CAF: Organise your Azure resources | [Organise your Azure resources](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-setup-guide/organize-resources) |
    | CAF: Enforce cloud governance policies | [Enforce cloud governance policies](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/govern/enforce-cloud-governance-policies) |
    | Azure: Tag support for resources | [Tag support for Azure resources](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-support) |

    ---

    ## Module

    - **Terraform Registry:** [diegosrp/tag-governance-workbook/azurerm](https://registry.terraform.io/modules/diegosrp/tag-governance-workbook/azurerm)
    - **Source Repository:** [github.com/diegosrp/terraform-azurerm-tag-governance-workbook](https://github.com/diegosrp/terraform-azurerm-tag-governance-workbook)
  EOT

  # Builds: isempty(trim(' ', tostring(tags['env']))) or isempty(trim(' ', tostring(tags['app']))) or ...
  kql_noncompliant_filter = join(" or ", [
    for tag in local.mandatory_tags_normalized :
    "isempty(trim(' ', tostring(tags['${tag}'])))"
  ])

  # Builds: dynamic(['env','app','costcenter','businessunit','criticality','opsteam'])
  kql_tag_dynamic_array = "dynamic([${join(",", [for t in local.mandatory_tags_normalized : "'${t}'"])}])"

  # Builds individual extend lines (used in noncompliant tables):
  #   | extend Tag1Missing = isempty(trim(' ', tostring(tags['env'])))
  #   | extend Tag2Missing = isempty(trim(' ', tostring(tags['app'])))
  #   ...
  kql_tag_extends = join("\n", [
    for i, tag in local.mandatory_tags_normalized :
    "    | extend Tag${i + 1}Missing = isempty(trim(' ', tostring(tags['${tag}'])))"
  ])

  # Builds: strcat_array(array_concat(iff(Tag1Missing, dynamic(['env']), dynamic([])), ...), ', ')
  kql_missing_tags_concat = "strcat_array(array_concat(${join(",", [
    for i, tag in local.mandatory_tags_normalized :
    "iff(Tag${i + 1}Missing, dynamic(['${tag}']), dynamic([]))"
  ])}), ', ')"

  # Builds: Tag1Missing or Tag2Missing or ...
  kql_noncompliant_or_tags = join(" or ", [
    for i in range(length(local.mandatory_tags_normalized)) :
    "Tag${i + 1}Missing"
  ])

  # Single map passed to every KQL templatefile() call
  kql_vars = {
    noncompliant_filter  = local.kql_noncompliant_filter
    tag_dynamic_array    = local.kql_tag_dynamic_array
    tag_extends          = local.kql_tag_extends
    missing_tags_concat  = local.kql_missing_tags_concat
    noncompliant_or_tags = local.kql_noncompliant_or_tags
    mandatory_tags_count = length(local.mandatory_tags_normalized)
    mg_exclusion_suffix  = local.kql_mg_exclusion_suffix
    mg_excluded_list     = local.kql_mg_excluded_list
  }
}
