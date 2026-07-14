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
    ResourceContainers
    | where type =~ 'microsoft.resources/subscriptions/resourcegroups'
${tag_extends}
    | extend MissingTags = ${missing_tags_concat}
    | extend NonCompliant = ${noncompliant_or_tags}
    | where NonCompliant
    | extend tag = tostring(tags)
    | extend Tags = iff(tag == '{}' or isempty(tag) or isnull(tag), '', tag)
    | extend ResourceGroup = id
    | extend ResourceGroupLink = strcat('https://portal.azure.com/#@', tenantId, '/resource', id, '/tags')
    | extend SubscriptionID = strcat('/subscriptions/', subscriptionId)
    | extend SubscriptionLink = strcat('https://portal.azure.com/#@', tenantId, '/resource/subscriptions/', subscriptionId, '/overview')
    | project subscriptionId, ResourceGroup, ResourceGroupLink, SubscriptionID, SubscriptionLink, Tags, MissingTags
) on $left.subscriptionId == $right.subscriptionId
| extend ResourceGroupSort = tolower(ResourceGroup)
| order by ResourceGroupSort asc
| project ResourceGroup, ResourceGroupLink, SubscriptionID, SubscriptionLink, Tags, MissingTags
