# Safe Apply Workflow

## Dev

Dev can be applied locally while learning, but still follow:

```bash
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

## Prod

Production should use:

```text
branch
  -> PR
  -> fmt/validate/plan
  -> plan review
  -> security/cost checks
  -> approval
  -> apply by CI identity
```

## Do Not

- Apply prod from laptop.
- Apply when plan has unexpected destroy.
- Store secrets in tfvars.
- Share Terraform state files.
- Use prod service account in dev.

