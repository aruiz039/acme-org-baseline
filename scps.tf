locals {
  scps = {
    deny_leaving_org = {
      file        = "policies/deny-leaving-org.json"
      description = "Prevent accounts from leaving the org"
      targets = [
        { name = "root", id = local.root_id }
      ]
    }
    region_restriction = {
      file        = "policies/region-restriction.json"
      description = "Restrict to us-east-1 and us-west-2"
      targets = [
        { name = "root", id = local.root_id }
      ]
    }
    protect_cloudtrail = {
      file        = "policies/protect-cloudtrail.json"
      description = "Prevent CloudTrail tampering"
      targets = [
        { name = "root", id = local.root_id }
      ]
    }
    deny_root = {
      file        = "policies/deny-root.json"
      description = "Deny actions by the root user"
      targets = [
        { name = "root", id = local.root_id }
      ]
    }
    require_imdsv2 = {
      file        = "policies/require-imdsv2.json"
      description = "Require IMDSv2 on EC2 instances"
      targets = [
        { name = "workloads", id = aws_organizations_organizational_unit.workloads.id }
      ]
    }
  }
}

resource "aws_organizations_policy" "scp" {
  for_each = local.scps

  name        = each.key
  description = each.value.description
  type        = "SERVICE_CONTROL_POLICY"
  content     = file(each.value.file)
}

# Flatten policy x target combinations.
# Keys are built from static strings (policy name + target name) so Terraform
# can resolve the for_each map at plan time without needing apply-time IDs.
locals {
  scp_attachments = flatten([
    for k, v in local.scps : [
      for target in v.targets : {
        key       = "${k}-${target.name}"
        policy_id = aws_organizations_policy.scp[k].id
        target_id = target.id
      }
    ]
  ])
}

resource "aws_organizations_policy_attachment" "scp" {
  for_each = { for a in local.scp_attachments : a.key => a }

  policy_id = each.value.policy_id
  target_id = each.value.target_id
}