ResourceContainers
| where type =~ 'microsoft.resources/subscriptions'
| project subscriptionId, Subscription = name
| join kind=inner (
    Resources
    | union (ResourceContainers | where type =~ 'microsoft.resources/subscriptions/resourcegroups')
    | extend NonCompliant = ${noncompliant_filter}
    | summarize Total = count(), Compliant = countif(not(NonCompliant)), ['Non-Compliant'] = countif(NonCompliant) by subscriptionId
) on subscriptionId
| extend ['Compliance %'] = round(100.0 * Compliant / Total, 1)
| project Subscription, ['Compliance %'], Compliant, ['Non-Compliant'], Total
| order by ['Compliance %'] desc
