[all:vars]
ansible_connection=ssh
ansible_user=${admin_user}

[database]
${database_node_float_ip}
