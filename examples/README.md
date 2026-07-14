# Examples

This directory contains runnable examples for the `diegosrp/tag-governance-workbook/azurerm` module.

## Available examples

- [basic](./basic/) - Use when you want to work only with CAF tags using the Microsoft CAF catalog as the reference baseline.
- [custom](./custom/) - Use when your governance model includes tags outside CAF and you want to maintain a custom catalog.
- [excluded-management-groups](./excluded-management-groups/) - Use when specific management groups have different mandatory tag requirements, such as sandbox environments with lighter tag controls.

## Files in each example

- [basic/basic.tf](./basic/basic.tf) - Minimal Registry-based example with baseline mandatory tags.
- [custom/custom-tag-catalog.tf](./custom/custom-tag-catalog.tf) - Registry-based example that extends the workbook with custom tag metadata.
- [excluded-management-groups/excluded-management-groups.tf](./excluded-management-groups/excluded-management-groups.tf) - Registry-based example that excludes selected management groups from scope.

## How to run an example

1. Change into the example directory.
2. Initialize Terraform.
3. Review the plan.
4. Apply changes.

```bash
terraform init
terraform plan
terraform apply
```

## Notes

- Each example uses the public module source from Terraform Registry.
- Update input values (for example, naming, location, and tags) to match your environment before applying.
