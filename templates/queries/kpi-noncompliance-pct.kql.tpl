Resources
| union (ResourceContainers | where type =~ 'microsoft.resources/subscriptions/resourcegroups')
| extend NonCompliant = ${noncompliant_filter}
| summarize Total = count(), NonCompliantCount = countif(NonCompliant)
| extend Value = iff(Total == 0, 0.0, round(100.0 * NonCompliantCount / Total, 1))
| extend Name = 'Non-Compliant %'
| project Name, Value
