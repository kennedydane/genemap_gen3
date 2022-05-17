resource "openstack_compute_instance_v2" "database_node" {
  name            = "database"
  image_name      = "${var.database_image_name}"
  flavor_name     = "${var.database_node_flavour}"
  key_pair        = "${openstack_compute_keypair_v2.gen3_ssh_key.name}"
  security_groups = ["${openstack_networking_secgroup_v2.gen3_ssh.name}"]

  network {
    name = "${openstack_networking_network_v2.gen3_network.name}"
  }
}

#output "compute_instances" {
#  description = "All the slurm compute nodes' names"
#  value       = "${openstack_compute_instance_v2.slurm_compute.*.name}"
#}
#
#output "compute_ips" {
#  description = "All the slurm compute nodes' ip addresses"
#  value = "${openstack_compute_instance_v2.slurm_compute.*.access_ip_v4}"
#}