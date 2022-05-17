// variables.pkr.hcl
// Packer Variables

variable "admin_user" {
  type = string
  description = "Login name for admin user"
}

variable "base_image_name" {
  type = string
  description = "Name to use for Base image"
}

variable "base_image_source" {
  type = string
  description = "Source URL for base image"
}

variable "base_image_source_format" {
  type = string
  description = "Image format of base image (qcow2 / raw / …)"
}

variable "build_image_flavour" {
  type = string
  description = "Virtual Image Flavour to be used when building images"
}

variable "database_image_name" {
  type = string
  description = "Name to give the database image"
}

variable "docker_image_name" {
  type = string
  description = "Name to give the docker image"
}

variable "floating_ip_network_id" {
  description = "The name of the Floating IP network in your OpenStack"
  type = string
}

variable "network_ids" {
  type = list(string)
  description = "Name of networks to be used when building images"
}

variable "security_groups" {
  type = list(string)
  description = "Security groups to be used (this should include an incoming ssh rule…)"
}

# Terraform Variables

variable "name_prefix" {
  type = string
  description = "Name used in terraform infrastructure"
}