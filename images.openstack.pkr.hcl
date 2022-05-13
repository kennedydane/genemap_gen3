source "openstack" "base_image" {
  flavor       = "${var.build_image_flavour}"
  image_name   = "${var.base_image_name}"
  source_image = "${var.base_image_source}"
  ssh_username = "${var.admin_user}"
}

build {
  sources = ["source.openstack.base_image"]
}