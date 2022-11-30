variable "env_name" {
  type = string
}

variable "location1" {
  type = string
}

variable "location2" {
  type = string
}

variable "cf_zone_id" {
  type = string
}

variable "cf_domain" {
  type = string
}

variable "key_rotation_iteration" {
  type    = string
  default = "1"
}
