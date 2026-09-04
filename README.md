# Terraform Day 10 - Azure Landing Zone

Trainer-style multi-root project using reusable local modules.

## Deployment order
1. Create the backend Resource Group, Storage Account and container manually in Azure Portal.
2. Replace backend names and authentication placeholders in each deployment `main.tf` / `terraform.tfvars`.
3. Deploy `hub` first.
4. Deploy `dev`, `test`, and `prod` next.
5. Deploy `governance` only if your account has Policy permissions.

## Important
- Run Terraform inside one deployment folder at a time.
- Each deployment uses a different state key.
- Firewall, Bastion and VPN Gateway are disabled by default to avoid cost.
- Never commit real client secrets or `terraform.tfvars`.
