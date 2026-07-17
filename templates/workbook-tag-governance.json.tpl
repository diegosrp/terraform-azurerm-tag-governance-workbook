{
  "version": "Notebook/1.0",
  "items": [
    {
      "type": 9,
      "content": {
        "version": "KqlParameterItem/1.0",
        "parameters": [
          {
            "id": "mg-param-1",
            "version": "KqlParameterItem/1.0",
            "name": "ManagementGroups",
            "label": "Management Groups",
            "type": 2,
            "description": "Choose one or more management groups to scope subscriptions",
            "multiSelect": true,
            "quote": "'",
            "delimiter": ",",
            "query": ${jsonencode(query_param_mg)},
            "crossComponentResources": [
              "value::all"
            ],
            "typeSettings": {
              "additionalResourceOptions": [
                "value::all"
              ],
              "showDefault": false
            },
            "queryType": 1,
            "resourceType": "microsoft.resourcegraph/resources"
          },
          {
            "id": "sub-param-1",
            "version": "KqlParameterItem/1.0",
            "name": "Subscription",
            "label": "Subscriptions",
            "type": 6,
            "description": "Choose one or more subscriptions to analyze tag compliance",
            "multiSelect": true,
            "quote": "'",
            "delimiter": ", ",
            "query": ${jsonencode(query_param_sub)},
            "crossComponentResources": [
              "value::all"
            ],
            "typeSettings": {
              "additionalResourceOptions": [
                "value::all"
              ],
              "includeAll": true,
              "showDefault": false
            },
            "defaultValue": "value::all",
            "queryType": 1,
            "resourceType": "microsoft.resourcegraph/resources"
          }
        ],
        "style": "above",
        "queryType": 1,
        "resourceType": "microsoft.resources/tenants"
      },
      "name": "subscriptions"
    },
    {
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "editable",
        "items": [
          {
            "type": 11,
            "content": {
              "version": "LinkItem/1.0",
              "style": "tabs",
              "links": [
                {
                  "id": "tab-guide-uuid",
                  "cellValue": "selectedTab",
                  "linkTarget": "parameter",
                  "linkLabel": "Guide",
                  "subTarget": "Guide",
                  "style": "link"
                },
                {
                  "id": "tab-summary-uuid",
                  "cellValue": "selectedTab",
                  "linkTarget": "parameter",
                  "linkLabel": "Summary",
                  "subTarget": "Summary",
                  "style": "link"
                },
                {
                  "id": "tab-inventory-uuid",
                  "cellValue": "selectedTab",
                  "linkTarget": "parameter",
                  "linkLabel": "Inventory",
                  "subTarget": "Inventory",
                  "style": "link"
                }
              ]
            },
            "name": "tab-links"
          },
          {
            "type": 1,
            "content": {
              "json": ${jsonencode(guide_intro_markdown)}
            },
            "conditionalVisibility": {
              "parameterName": "selectedTab",
              "comparison": "isEqualTo",
              "value": "Guide"
            },
            "name": "guide-intro"
          },
          {
            "type": 12,
            "content": {
              "version": "NotebookGroup/1.0",
              "groupType": "editable",
              "title": "Tag Compliance Overview",
              "items": [
                {
                  "type": 3,
                  "content": {
                    "version": "KqlItem/1.0",
                    "query": ${jsonencode(query_kpi_mandatory_tags)},
                    "size": 3,
                    "queryType": 1,
                    "resourceType": "microsoft.resourcegraph/resources",
                    "crossComponentResources": [
                      "{Subscription}"
                    ],
                    "visualization": "tiles",
                    "tileSettings": {
                      "titleContent": {
                        "columnMatch": "Name",
                        "formatter": 1
                      },
                      "leftContent": {
                        "columnMatch": "Value",
                        "formatter": 1,
                        "numberFormat": {
                          "unit": 0,
                          "options": {
                            "style": "decimal",
                            "useGrouping": true
                          }
                        }
                      },
                      "showBorder": true
                    }
                  },
                  "customWidth": "16",
                  "name": "kpi-mandatory-tags",
                  "styleSettings": {
                    "padding": "0",
                    "margin": "0"
                  }
                },
                {
                  "type": 3,
                  "content": {
                    "version": "KqlItem/1.0",
                    "query": ${jsonencode(query_kpi_evaluated)},
                    "size": 3,
                    "queryType": 1,
                    "resourceType": "microsoft.resourcegraph/resources",
                    "crossComponentResources": [
                      "{Subscription}"
                    ],
                    "visualization": "tiles",
                    "tileSettings": {
                      "titleContent": {
                        "columnMatch": "Name",
                        "formatter": 1
                      },
                      "leftContent": {
                        "columnMatch": "Value",
                        "formatter": 1,
                        "numberFormat": {
                          "unit": 0,
                          "options": {
                            "style": "decimal",
                            "useGrouping": true
                          }
                        }
                      },
                      "showBorder": true
                    }
                  },
                  "customWidth": "16",
                  "name": "kpi-resources-evaluated",
                  "styleSettings": {
                    "padding": "0",
                    "margin": "0"
                  }
                },
                {
                  "type": 3,
                  "content": {
                    "version": "KqlItem/1.0",
                    "query": ${jsonencode(query_kpi_compliance_pct)},
                    "size": 3,
                    "queryType": 1,
                    "resourceType": "microsoft.resourcegraph/resources",
                    "crossComponentResources": [
                      "{Subscription}"
                    ],
                    "visualization": "tiles",
                    "tileSettings": {
                      "titleContent": {
                        "columnMatch": "Name",
                        "formatter": 1
                      },
                      "leftContent": {
                        "columnMatch": "Value",
                        "formatter": 12,
                        "formatOptions": {
                          "palette": "greenRed"
                        },
                        "numberFormat": {
                          "unit": 1,
                          "options": {
                            "style": "decimal",
                            "useGrouping": true,
                            "maximumFractionDigits": 1
                          }
                        }
                      },
                      "showBorder": true
                    }
                  },
                  "customWidth": "16",
                  "name": "kpi-compliance-pct",
                  "styleSettings": {
                    "padding": "0",
                    "margin": "0"
                  }
                },
                {
                  "type": 3,
                  "content": {
                    "version": "KqlItem/1.0",
                    "query": ${jsonencode(query_kpi_noncompliance_pct)},
                    "size": 3,
                    "queryType": 1,
                    "resourceType": "microsoft.resourcegraph/resources",
                    "crossComponentResources": [
                      "{Subscription}"
                    ],
                    "visualization": "tiles",
                    "tileSettings": {
                      "titleContent": {
                        "columnMatch": "Name",
                        "formatter": 1
                      },
                      "leftContent": {
                        "columnMatch": "Value",
                        "formatter": 12,
                        "formatOptions": {
                          "palette": "redGreen"
                        },
                        "numberFormat": {
                          "unit": 1,
                          "options": {
                            "style": "decimal",
                            "useGrouping": true,
                            "maximumFractionDigits": 1
                          }
                        }
                      },
                      "showBorder": true
                    }
                  },
                  "customWidth": "16",
                  "name": "kpi-noncompliance-pct",
                  "styleSettings": {
                    "padding": "0",
                    "margin": "0"
                  }
                },
                {
                  "type": 3,
                  "content": {
                    "version": "KqlItem/1.0",
                    "query": ${jsonencode(query_kpi_compliant)},
                    "size": 3,
                    "queryType": 1,
                    "resourceType": "microsoft.resourcegraph/resources",
                    "crossComponentResources": [
                      "{Subscription}"
                    ],
                    "visualization": "tiles",
                    "tileSettings": {
                      "titleContent": {
                        "columnMatch": "Name",
                        "formatter": 1
                      },
                      "leftContent": {
                        "columnMatch": "Value",
                        "formatter": 1,
                        "numberFormat": {
                          "unit": 0,
                          "options": {
                            "style": "decimal",
                            "useGrouping": true
                          }
                        }
                      },
                      "showBorder": true
                    }
                  },
                  "customWidth": "16",
                  "name": "kpi-compliant",
                  "styleSettings": {
                    "padding": "0",
                    "margin": "0"
                  }
                },
                {
                  "type": 3,
                  "content": {
                    "version": "KqlItem/1.0",
                    "query": ${jsonencode(query_kpi_noncompliant)},
                    "size": 3,
                    "queryType": 1,
                    "resourceType": "microsoft.resourcegraph/resources",
                    "crossComponentResources": [
                      "{Subscription}"
                    ],
                    "visualization": "tiles",
                    "tileSettings": {
                      "titleContent": {
                        "columnMatch": "Name",
                        "formatter": 1
                      },
                      "leftContent": {
                        "columnMatch": "Value",
                        "formatter": 12,
                        "numberFormat": {
                          "unit": 0,
                          "options": {
                            "style": "decimal",
                            "useGrouping": true,
                            "maximumFractionDigits": 0,
                            "notation": "standard"
                          }
                        }
                      },
                      "showBorder": true
                    }
                  },
                  "customWidth": "16",
                  "name": "kpi-noncompliant",
                  "styleSettings": {
                    "padding": "0",
                    "margin": "0"
                  }
                },
                {
                  "type": 3,
                  "content": {
                    "version": "KqlItem/1.0",
                    "query": ${jsonencode(query_chart_compliance_summary)},
                    "size": 0,
                    "title": "Compliance Status",
                    "showExportToExcel": true,
                    "queryType": 1,
                    "resourceType": "microsoft.resourcegraph/resources",
                    "crossComponentResources": [
                      "{Subscription}"
                    ],
                    "visualization": "piechart",
                    "chartSettings": {
                      "showLegend": false,
                      "ySettings": {
                        "numberFormatSettings": {
                          "unit": 0,
                          "options": {
                            "style": "decimal",
                            "useGrouping": true
                          }
                        }
                      },
                      "seriesLabelSettings": [
                        {
                          "seriesName": "1 Non-Compliant",
                          "label": "Non-Compliant",
                          "color": "red"
                        },
                        {
                          "seriesName": "2 Compliant",
                          "label": "Compliant",
                          "color": "green"
                        }
                      ]
                    }
                  },
                  "customWidth": "35",
                  "name": "chart-compliance-summary"
                },
                {
                  "type": 3,
                  "content": {
                    "version": "KqlItem/1.0",
                    "query": ${jsonencode(query_table_compliance_by_subscription)},
                    "size": 1,
                    "title": "By Subscription",
                    "showExportToExcel": true,
                    "queryType": 1,
                    "resourceType": "microsoft.resourcegraph/resources",
                    "crossComponentResources": [
                      "{Subscription}"
                    ],
                    "visualization": "table",
                    "gridSettings": {
                      "formatters": [
                        {
                          "columnMatch": "Subscription",
                          "formatter": 1
                        },
                        {
                          "columnMatch": "Compliance %",
                          "formatter": 8,
                          "formatOptions": {
                            "min": 0,
                            "max": 100,
                            "palette": "redGreen"
                          },
                          "numberFormat": {
                            "unit": 1,
                            "options": {
                              "style": "decimal",
                              "maximumFractionDigits": 1
                            }
                          }
                        }
                      ],
                      "filter": true
                    },
                    "sortBy": []
                  },
                  "customWidth": "65",
                  "name": "table-compliance-by-subscription"
                },
                {
                  "type": 1,
                  "content": {
                    "json": "<br/>\n\n---"
                  },
                  "name": "separator-chart-rows"
                },
                {
                  "type": 3,
                  "content": {
                    "version": "KqlItem/1.0",
                    "query": ${jsonencode(query_chart_tag_coverage)},
                    "size": 1,
                    "title": "Mandatory Tag Coverage",
                    "showExportToExcel": true,
                    "queryType": 1,
                    "resourceType": "microsoft.resourcegraph/resources",
                    "crossComponentResources": [
                      "{Subscription}"
                    ],
                    "visualization": "barchart",
                    "chartSettings": {
                      "xAxis": "Tag",
                      "yAxis": [
                        "Coverage %"
                      ],
                      "showLegend": false,
                      "showDataLabels": false,
                      "seriesLabelSettings": [
                        { "seriesName": "env", "color": "blue" },
                        { "seriesName": "app", "color": "blue" },
                        { "seriesName": "costcenter", "color": "blue" },
                        { "seriesName": "businessunit", "color": "blue" },
                        { "seriesName": "criticality", "color": "blue" },
                        { "seriesName": "opsteam", "color": "blue" }
                      ],
                      "ySettings": {
                        "numberFormatSettings": {
                          "unit": 1,
                          "options": {
                            "style": "decimal",
                            "maximumFractionDigits": 1
                          }
                        }
                      }
                    }
                  },
                  "customWidth": "35",
                  "name": "chart-mandatory-tags-coverage"
                },
                {
                  "type": 3,
                  "content": {
                    "version": "KqlItem/1.0",
                    "query": ${jsonencode(query_table_top_noncompliant_resource_types)},
                    "size": 1,
                    "title": "Top 10 Non-Compliant Resource Types",
                    "showExportToExcel": true,
                    "queryType": 1,
                    "resourceType": "microsoft.resourcegraph/resources",
                    "crossComponentResources": [
                      "{Subscription}"
                    ],
                    "visualization": "table",
                    "gridSettings": {
                      "formatters": [
                        {
                          "columnMatch": "Resource Type",
                          "formatter": 1
                        },
                        {
                          "columnMatch": "Non-Compliance %",
                          "formatter": 8,
                          "formatOptions": {
                            "min": 0,
                            "max": 100,
                            "palette": "greenRed"
                          },
                          "numberFormat": {
                            "unit": 1,
                            "options": {
                              "style": "decimal",
                              "maximumFractionDigits": 1
                            }
                          }
                        }
                      ],
                      "filter": true,
                      "sortBy": [
                        {
                          "itemKey": "Non-Compliance %",
                          "sortOrder": 2
                        }
                      ]
                    },
                    "sortBy": [
                      {
                        "itemKey": "Non-Compliance %",
                        "sortOrder": 2
                      }
                    ]
                  },
                  "customWidth": "65",
                  "name": "table-top-noncompliant-resource-types"
                }
              ]
            },
            "conditionalVisibility": {
              "parameterName": "selectedTab",
              "comparison": "isEqualTo",
              "value": "Summary"
            },
            "name": "tag-summary-section",
            "styleSettings": {
              "showBorder": true
            }
          },
          {
            "type": 12,
            "content": {
              "version": "NotebookGroup/1.0",
              "groupType": "editable",
              "title": "Non-Compliant Tag Inventory",
              "items": [
                {
                  "type": 3,
                  "content": {
                    "version": "KqlItem/1.0",
                    "query": ${jsonencode(query_piechart_rg_compliance)},
                    "size": 4,
                    "title": "Resource Groups",
                    "showExportToExcel": true,
                    "queryType": 1,
                    "resourceType": "microsoft.resourcegraph/resources",
                    "crossComponentResources": [
                      "{Subscription}"
                    ],
                    "visualization": "piechart",
                    "chartSettings": {
                      "showLegend": false,
                      "ySettings": {
                        "numberFormatSettings": {
                          "unit": 0,
                          "options": {
                            "style": "decimal",
                            "useGrouping": true
                          }
                        }
                      },
                      "seriesLabelSettings": [
                        {
                          "seriesName": "1 Non-Compliant",
                          "label": "Non-Compliant",
                          "color": "red"
                        },
                        {
                          "seriesName": "2 Compliant",
                          "label": "Compliant",
                          "color": "green"
                        }
                      ]
                    }
                  },
                  "customWidth": "50",
                  "name": "piechart-rg-compliance"
                },
                {
                  "type": 3,
                  "content": {
                    "version": "KqlItem/1.0",
                    "query": ${jsonencode(query_piechart_resource_compliance)},
                    "size": 4,
                    "title": "Resources",
                    "showExportToExcel": true,
                    "queryType": 1,
                    "resourceType": "microsoft.resourcegraph/resources",
                    "crossComponentResources": [
                      "{Subscription}"
                    ],
                    "visualization": "piechart",
                    "chartSettings": {
                      "showLegend": false,
                      "ySettings": {
                        "numberFormatSettings": {
                          "unit": 0,
                          "options": {
                            "style": "decimal",
                            "useGrouping": true
                          }
                        }
                      },
                      "seriesLabelSettings": [
                        {
                          "seriesName": "1 Non-Compliant",
                          "label": "Non-Compliant",
                          "color": "red"
                        },
                        {
                          "seriesName": "2 Compliant",
                          "label": "Compliant",
                          "color": "green"
                        }
                      ]
                    }
                  },
                  "customWidth": "50",
                  "name": "piechart-resource-compliance"
                },
                {
                  "type": 3,
                  "content": {
                    "version": "KqlItem/1.0",
                    "query": ${jsonencode(query_table_noncompliant_rg)},
                    "size": 1,
                    "showAnalytics": true,
                    "title": "Non-Compliant Resource Groups",
                    "noDataMessage": "All resource groups are compliant with the required tags",
                    "noDataMessageStyle": 3,
                    "showExportToExcel": true,
                    "queryType": 1,
                    "resourceType": "microsoft.resourcegraph/resources",
                    "crossComponentResources": [
                      "{Subscription}"
                    ],
                    "visualization": "table",
                    "gridSettings": {
                      "formatters": [
                        {
                          "columnMatch": "ResourceGroup",
                          "formatter": 13,
                          "formatOptions": {
                            "linkTarget": "Url",
                            "linkColumn": "ResourceGroupLink",
                            "showIcon": true,
                            "customColumnWidthSetting": "35ch"
                          }
                        },
                        {
                          "columnMatch": "ResourceGroupLink",
                          "formatter": 5
                        },
                        {
                          "columnMatch": "SubscriptionID",
                          "formatter": 13,
                          "formatOptions": {
                            "linkTarget": "Url",
                            "linkColumn": "SubscriptionLink",
                            "showIcon": true,
                            "customColumnWidthSetting": "24ch"
                          }
                        },
                        {
                          "columnMatch": "SubscriptionLink",
                          "formatter": 5
                        },
                        {
                          "columnMatch": "MissingTags",
                          "formatter": 0,
                          "formatOptions": {
                            "customColumnWidthSetting": "47ch"
                          }
                        },
                        {
                          "columnMatch": "Tags",
                          "formatter": 0,
                          "formatOptions": {
                            "customColumnWidthSetting": "78ch"
                          }
                        }
                      ],
                      "filter": true
                    },
                    "sortBy": []
                  },
                  "customWidth": "100",
                  "name": "table-noncompliant-rg"
                },
                {
                  "type": 3,
                  "content": {
                    "version": "KqlItem/1.0",
                    "query": ${jsonencode(query_table_noncompliant_resources)},
                    "size": 1,
                    "showAnalytics": true,
                    "title": "Non-Compliant Resources",
                    "noDataMessage": "All resources are compliant with the required tags",
                    "noDataMessageStyle": 3,
                    "showExportToExcel": true,
                    "queryType": 1,
                    "resourceType": "microsoft.resourcegraph/resources",
                    "crossComponentResources": [
                      "{Subscription}"
                    ],
                    "visualization": "table",
                    "gridSettings": {
                      "formatters": [
                        {
                          "columnMatch": "ResourceGroup",
                          "formatter": 13,
                          "formatOptions": {
                            "linkTarget": "Url",
                            "linkColumn": "ResourceGroupLink",
                            "showIcon": true,
                            "customColumnWidthSetting": "25ch"
                          }
                        },
                        {
                          "columnMatch": "Resource",
                          "formatter": 13,
                          "formatOptions": {
                            "linkTarget": "Url",
                            "linkColumn": "ResourceLink",
                            "showIcon": true,
                            "customColumnWidthSetting": "35ch"
                          }
                        },
                        {
                          "columnMatch": "ResourceGroupLink",
                          "formatter": 5
                        },
                        {
                          "columnMatch": "ResourceLink",
                          "formatter": 5
                        },
                        {
                          "columnMatch": "SubscriptionID",
                          "formatter": 13,
                          "formatOptions": {
                            "linkTarget": "Url",
                            "linkColumn": "SubscriptionLink",
                            "showIcon": true,
                            "customColumnWidthSetting": "22ch"
                          }
                        },
                        {
                          "columnMatch": "SubscriptionLink",
                          "formatter": 5
                        },
                        {
                          "columnMatch": "MissingTags",
                          "formatter": 0,
                          "formatOptions": {
                            "customColumnWidthSetting": "47ch"
                          }
                        },
                        {
                          "columnMatch": "Tags",
                          "formatter": 0,
                          "formatOptions": {
                            "customColumnWidthSetting": "55ch"
                          }
                        }
                      ],
                      "filter": true
                    },
                    "sortBy": []
                  },
                  "customWidth": "100",
                  "name": "table-noncompliant-resources"
                }
              ]
            },
            "conditionalVisibility": {
              "parameterName": "selectedTab",
              "comparison": "isEqualTo",
              "value": "Inventory"
            },
            "name": "tag-inventory-section",
            "styleSettings": {
              "showBorder": true
            }
          }
        ]
      },
      "name": "workbook"
    }
  ],
  "fallbackResourceIds": [
    "Azure Monitor"
  ],
  "$schema": "https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json"
}
