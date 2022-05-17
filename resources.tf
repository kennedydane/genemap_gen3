resource "openstack_compute_keypair_v2" "gen3_ssh_key" {
  name       = "${var.name_prefix}-sshkey"
  public_key = "${var.ssh_public_key}"
}

resource "local_file" "hosts_cfg" {
  content = templatefile("templates/hosts.tpl",
    {
      database_node_float_ip = openstack_networking_floatingip_v2.database_float_ip.address
      admin_user = var.admin_user
    }
  )
  filename = "inventory"
}