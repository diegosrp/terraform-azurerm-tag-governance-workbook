Resources
| summarize c = count()
| project Name = 'Mandatory Tags', Value = ${mandatory_tags_count}
