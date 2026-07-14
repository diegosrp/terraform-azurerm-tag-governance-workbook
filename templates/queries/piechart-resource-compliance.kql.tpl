ResourceContainers
| where type =~ 'microsoft.resources/subscriptions'
| extend mgParent = properties.managementGroupAncestorsChain
| mv-expand mgParent
| extend mgName = tostring(mgParent.name)
| summarize
    hasSelected = countif('value::all' in ({ManagementGroups}) or mgName in ({ManagementGroups})) > 0,
    hasExcluded = countif(mgName in~ (${mg_excluded_list})) > 0
    by subscriptionId
| where hasSelected and not(hasExcluded)
| project subscriptionId
| join kind=inner (
    Resources
    | extend NonCompliant = ${noncompliant_filter}
    | extend Status = iff(NonCompliant, '1 Non-Compliant', '2 Compliant')
    | summarize Count = count() by Status, subscriptionId
) on subscriptionId
| summarize Count = sum(Count) by Status
