# IAM Policies

## `github-actions-deploy-policy.json`

Scoped policy to replace `AdministratorAccess` on the `github-actions-beworking-orchestration` role.

Covers everything the current workflows do:
- ECS task-def registration + service updates (for `auto-deploy-taskdef.yml`)
- CloudFormation stack CRUD on `beworking-*` stacks (for `deploy-cloudformation.yml`)
- Application Auto Scaling (for staging-scaling stack resources)
- `iam:PassRole` scoped to ECS task roles and Application Auto Scaling service role
- ECR read (image URI validation)
- CloudWatch Logs read (troubleshooting)

### Migration (when ready)

Not applied yet — applying it requires verifying nothing else in CI depends on admin permissions.

```bash
# 1. Create the scoped policy
aws iam create-policy \
  --policy-name github-actions-beworking-deploy \
  --policy-document file://github-actions-deploy-policy.json

# 2. Attach to the role
aws iam attach-role-policy \
  --role-name github-actions-beworking-orchestration \
  --policy-arn arn:aws:iam::905418223611:policy/github-actions-beworking-deploy

# 3. Run a test deploy (push a no-op change to main) to verify nothing breaks

# 4. Only after verification — detach AdministratorAccess
aws iam detach-role-policy \
  --role-name github-actions-beworking-orchestration \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

Keep the JSON file authoritative — edit it here, then re-create the policy (or use `create-policy-version`) on change.
