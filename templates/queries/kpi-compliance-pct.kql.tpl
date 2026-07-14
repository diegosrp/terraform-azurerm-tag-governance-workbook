Resources
| union (ResourceContainers | where type =~ 'microsoft.resources/subscriptions/resourcegroups')
| extend NonCompliant = ${noncompliant_filter}
| summarize Total = count(), Compliant = countif(not(NonCompliant))
| extend Value = iff(Total == 0, 0.0, round(100.0 * Compliant / Total, 1))
| extend Name = 'Compliance %'
| project Name, Value
