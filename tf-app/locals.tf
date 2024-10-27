locals {
    image_tag = one(data.terraform_remote_state.tag[*].outputs.image_tag) != null ? one(data.terraform_remote_state.tag[*].outputs.image_tag) : var.image_tag
    previous_stage = var.env == "dev" ? "null" : var.env == "qa" ? "dev" : "qa"
}
