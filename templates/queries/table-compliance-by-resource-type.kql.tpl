Resources
| union (ResourceContainers | where type =~ 'microsoft.resources/subscriptions/resourcegroups')
| extend NonCompliant = ${noncompliant_filter}
| summarize Total = count(), Compliant = countif(not(NonCompliant)), ['Non-Compliant'] = countif(NonCompliant) by ['Resource Type'] = type
| extend ['Compliance %'] = round(100.0 * Compliant / Total, 1)
| top 15 by Total
| project ['Resource Type'], ['Compliance %'], Compliant, ['Non-Compliant'], Total
| order by Total desc
