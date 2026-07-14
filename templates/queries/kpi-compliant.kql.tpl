Resources
| union (ResourceContainers | where type =~ 'microsoft.resources/subscriptions/resourcegroups')
| extend NonCompliant = ${noncompliant_filter}
| where not(NonCompliant)
| summarize Value = count()
| extend Name = 'Compliant'
| project Name, Value
