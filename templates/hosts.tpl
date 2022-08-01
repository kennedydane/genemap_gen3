[all:vars]
ansible_connection=ssh
ansible_ssh_extra_args="-o ControlPersist=15m -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o AddKeysToAgent=no -o IdentitiesOnly=yes -v"
ansible_ssh_private_key_file=~/.ssh/ilifu/id_rsa
ansible_user=${admin_user}
postgres_user=${postgres_user}
postgres_password=${postgres_password}
postgres_fence_user=${postgres_fence_user}
postgres_fence_password=${postgres_fence_password}
postgres_peregrine_user=${postgres_peregrine_user}
postgres_peregrine_password=${postgres_peregrine_password}
postgres_sheepdog_user=${postgres_sheepdog_user}
postgres_sheepdog_password=${postgres_sheepdog_password}
postgres_indexd_user=${postgres_indexd_user}
postgres_indexd_password=${postgres_indexd_password}
postgres_arborist_user=${postgres_arborist_user}
postgres_arborist_password=${postgres_arborist_password}

[all:children]
database_nodes
docker_nodes

[database_nodes]
db ansible_host=${database_node_float_ip} private_ip=${database_node_private_ip}

[docker_nodes]
docker ansible_host=${docker_node_private_ip} private_ip=${docker_node_private_ip}

[docker_nodes:vars]
ansible_ssh_extra_args="-o ProxyCommand='ssh -o ControlPersist=15m -A -i ~/.ssh/ilifu/id_rsa ${admin_user}@${database_node_float_ip} nc %h 22'"

