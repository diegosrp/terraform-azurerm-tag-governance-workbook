Resources
| union (ResourceContainers | where type =~ 'microsoft.resources/subscriptions/resourcegroups')
| extend NonCompliant = ${noncompliant_filter}
| where NonCompliant
| summarize Value = count()
| extend Name = 'Non-Compliant'
| project Name, Value
