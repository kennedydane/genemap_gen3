source "openstack" "base_image" {
  flavor       = "${var.build_image_flavour}"
  image_name   = "${var.base_image_name}"
  external_source_image_url = "${var.base_image_source}"
  external_source_image_format = "${var.base_image_source_format}"
  ssh_username = "${var.admin_user}"
  networks = "${var.network_ids}"
  floating_ip_network = "${var.floating_ip_network_id}"
  security_groups = "${var.security_groups}"
  metadata = {
    hw_disk_bus = "scsi"
    hw_qemu_guest_agent = "yes",
    hw_rng_model = "virtio",
    hw_scsi_model = "virtio-scsi",
    hw_vif_model = "virtio"
  }
}

source "openstack" "database_image" {
  flavor       = "${var.build_image_flavour}"
  image_name   = "${var.database_image_name}"
  source_image_name = "${var.base_image_name}"
  ssh_username = "${var.admin_user}"
  networks = "${var.network_ids}"
  floating_ip_network = "${var.floating_ip_network_id}"
  security_groups = "${var.security_groups}"
  metadata = {
    hw_disk_bus = "scsi"
    hw_qemu_guest_agent = "yes",
    hw_rng_model = "virtio",
    hw_scsi_model = "virtio-scsi",
    hw_vif_model = "virtio"
  }
}

build {
  name = "step1"
  sources = ["source.openstack.base_image"]
}

build {
  name = "step2"
  sources = ["source.openstack.database_image"]
}