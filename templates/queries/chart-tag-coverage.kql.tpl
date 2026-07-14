Resources
| union (ResourceContainers | where type =~ 'microsoft.resources/subscriptions/resourcegroups')
| mv-expand TagName = ${tag_dynamic_array} to typeof(string)
| extend HasTag = isnotempty(trim(' ', tostring(tags[TagName])))
| summarize Total = count(), Present = countif(HasTag) by Tag = TagName
| extend ['Coverage %'] = round(100.0 * Present / Total, 1)
| project Tag, ['Coverage %']
| order by ['Coverage %'] desc
