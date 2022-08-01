resource "openstack_compute_keypair_v2" "gen3_ssh_key" {
  name       = "${var.name_prefix}-sshkey"
  public_key = var.ssh_public_key
}

resource "local_file" "hosts_cfg" {
  content = templatefile("templates/hosts.tpl",
    {
      database_node_float_ip = openstack_networking_floatingip_v2.database_float_ip.address
      database_node_private_ip = openstack_compute_instance_v2.database_node.network[0].fixed_ip_v4
      docker_node_private_ip   = openstack_compute_instance_v2.docker_node.network[0].fixed_ip_v4
      admin_user = var.admin_user
      postgres_user = var.postgres_user
      postgres_password = var.postgres_password
      postgres_fence_user = var.postgres_fence_user
      postgres_fence_password = var.postgres_fence_password
      postgres_peregrine_user = var.postgres_peregrine_user
      postgres_peregrine_password = var.postgres_peregrine_password
      postgres_sheepdog_user = var.postgres_sheepdog_user
      postgres_sheepdog_password = var.postgres_sheepdog_password
      postgres_indexd_user = var.postgres_indexd_user
      postgres_indexd_password = var.postgres_indexd_password
      postgres_arborist_user = var.postgres_arborist_user
      postgres_arborist_password = var.postgres_arborist_password
    }
  )
  filename = "inventory.ini"
}