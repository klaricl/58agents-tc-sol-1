output "image_tag" {
    value = var.image_tag
}

output "previous_stage" {
  value = "${local.previous_stage}.${var.app_part_short}"
}

output "prevoius_tag" {
  value = one(data.terraform_remote_state.tag[*].outputs.image_tag)
}

output "env" {
  value = var.env
}
