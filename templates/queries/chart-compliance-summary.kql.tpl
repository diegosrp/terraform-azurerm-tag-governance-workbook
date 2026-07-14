Resources
| union (ResourceContainers | where type =~ 'microsoft.resources/subscriptions/resourcegroups')
| extend NonCompliant = ${noncompliant_filter}
| summarize Count = count() by Status = iff(NonCompliant, '1 Non-Compliant', '2 Compliant')
