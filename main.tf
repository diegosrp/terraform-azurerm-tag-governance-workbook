resource "random_uuid" "main" {}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

resource "azurerm_application_insights_workbook" "main" {
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  name                = random_uuid.main.result

  display_name = var.workbook_display_name
  source_id    = "azure monitor"
  category     = "workbook"

  data_json = templatefile("${path.module}/templates/workbook-tag-governance.json.tpl", {
    guide_intro_markdown = local.guide_intro_markdown

    # Parameters (no tag logic - plain file reads)
    query_param_mg  = templatefile("${path.module}/templates/queries/param-mg.kql", local.kql_vars)
    query_param_sub = templatefile("${path.module}/templates/queries/param-sub.kql", local.kql_vars)

    # Summary Tab - KPIs
    query_kpi_mandatory_tags    = templatefile("${path.module}/templates/queries/kpi-mandatory-tags.kql.tpl", local.kql_vars)
    query_kpi_evaluated         = file("${path.module}/templates/queries/kpi-evaluated.kql")
    query_kpi_compliance_pct    = templatefile("${path.module}/templates/queries/kpi-compliance-pct.kql.tpl", local.kql_vars)
    query_kpi_noncompliance_pct = templatefile("${path.module}/templates/queries/kpi-noncompliance-pct.kql.tpl", local.kql_vars)
    query_kpi_compliant         = templatefile("${path.module}/templates/queries/kpi-compliant.kql.tpl", local.kql_vars)
    query_kpi_noncompliant      = templatefile("${path.module}/templates/queries/kpi-noncompliant.kql.tpl", local.kql_vars)

    # Summary Tab - Charts & Tables
    query_chart_compliance_summary              = templatefile("${path.module}/templates/queries/chart-compliance-summary.kql.tpl", local.kql_vars)
    query_table_compliance_by_subscription      = templatefile("${path.module}/templates/queries/table-compliance-by-subscription.kql.tpl", local.kql_vars)
    query_chart_tag_coverage                    = templatefile("${path.module}/templates/queries/chart-tag-coverage.kql.tpl", local.kql_vars)
    query_table_top_noncompliant_resource_types = templatefile("${path.module}/templates/queries/table-top-noncompliant-resource-types.kql.tpl", local.kql_vars)

    # Inventory Tab - Pie Charts
    query_piechart_rg_compliance       = templatefile("${path.module}/templates/queries/piechart-rg-compliance.kql.tpl", local.kql_vars)
    query_piechart_resource_compliance = templatefile("${path.module}/templates/queries/piechart-resource-compliance.kql.tpl", local.kql_vars)

    # Inventory Tab - Tables
    query_table_noncompliant_rg        = templatefile("${path.module}/templates/queries/table-noncompliant-rg.kql.tpl", local.kql_vars)
    query_table_noncompliant_resources = templatefile("${path.module}/templates/queries/table-noncompliant-resources.kql.tpl", local.kql_vars)
  })

  tags = azurerm_resource_group.main.tags
}
