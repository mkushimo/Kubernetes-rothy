resource "datadog_team_membership" "platform" {
  team_id = datadog_team.teams["platform-ro"].id
  user_id = datadog_user.platform["cloud"].id
}

# Create new team_membership resource
resource "datadog_team_membership" "cloud" {
  team_id = datadog_team.teams["admin"].id
  user_id = datadog_user.platform["platform"].id
}

data "datadog_role" "ro_role" {
  filter = "Datadog Read Only Role"
}

data "datadog_role" "st_role" {
  filter = "Datadog Standard Role"
}

locals {
  team = {
    admin       = { handle = "devops-team", name = "cloud" },
    platform-ro = { handle = "platform-team", name = "platform" },
    developers  = { handle = "dev-team", name = "dev" },
  }
  users = {
    platform = { name = "rothy", email = "rothydevops@gmail.com", roles = [data.datadog_role.st_role.id] },
    cloud    = { name = "rothytest", email = "rotimiakinboro@gmail.com", roles = [data.datadog_role.ro_role.id] },
  }
}

resource "datadog_team" "teams" {
  for_each    = local.team
  description = "Teams"
  handle      = each.value.handle
  name        = each.value.name
}

resource "datadog_user" "platform" {
  for_each = local.users
  email    = each.value.email
  name     = each.value.name
  roles    = each.value.roles
}