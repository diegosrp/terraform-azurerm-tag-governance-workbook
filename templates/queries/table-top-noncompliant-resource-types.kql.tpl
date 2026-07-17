Resources
| union (ResourceContainers | where type =~ 'microsoft.resources/subscriptions/resourcegroups')
| extend NonCompliant = ${noncompliant_filter}
| summarize Total = count(), Compliant = countif(not(NonCompliant)), ['Non-Compliant'] = countif(NonCompliant) by ['Resource Type'] = type
| where ['Non-Compliant'] > 0
| extend ['Non-Compliance %'] = round(100.0 * ['Non-Compliant'] / Total, 1)
| top 10 by ['Non-Compliance %'] desc
| project ['Resource Type'], ['Non-Compliance %'], ['Non-Compliant'], Compliant, Total
| order by ['Non-Compliance %'] desc, ['Non-Compliant'] desc, Total desc
