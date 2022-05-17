# eLwazi
Repository for keeping track of eLwazi private openstack gen3 infrastructure and
documentation.

# Setting up the infrastructure on OpenStack using Packer, Terraform and Ansible
The infrastructure is managed with a set of scripts that make use of
[Packer](https://www.packer.io/) (for creating the OpenStack virtual machine images
that are used), [Terraform](https://www.terraform.io/) (for deploying  infrastructure
on OpenStack), and finally [Ansible](https://www.ansible.com/) for configuring the
infrastructure.

## Installing software requirements on your machine
You will need to install [Packer](https://learn.hashicorp.com/tutorials/packer/get-started-install-cli)
and [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) in
addition to setting up a python virtual environment. Packer and Terraform can be
installed by setting up the appropriate repositories and installing using your OS's
package manager. The python virtual environment is ideally set up using pipenv by
running the `pipenv sync` command. Alternatively ensure you have a python virtual
environment with both the `python-openstackclient` and `ansible` packages installed.

### Initialising packer
It is important to run `packer init images.openstack.pkr.hcl` once in your environment. This
will ensure that the packer OpenStack plugin is installed.

## Get your OpenStack.rc file
Connect to your OpenStack dashboard, switch to the correct project then download the
`*-openrc.sh` file for your project (from the top-right dropdown menu). Before running most
of the commands here you will need to have "sourced" this file so that the environmental
variables are set so that packer/terraform can connect to your openstack infrastructure.
In otherwords once you have the `*-openrc.sh` file you will need to run
`source your-openrc.sh` and then the subsequent commands will work. Note you will need
your OpenStack login details at the time of sourcing.

## Setting up variables
There are only two files that should need configuring for this installation and these are
contain the variables that Packer/Terraform and Ansible use.

### Packer and Terraform
The Packer and Terraform variables should be in a file named `variables.auto.hcl` and this
can be made by copying the template file, i.e. `cp variables.auto.hcl.template variables.auto.hcl`.
Note that there are symbolic link files (`gen3.auto.tfvars` and
`gen3.auto.pkrvars.hcl`) that point at `variables.auto.hcl` and are auto-loaded by Packer
and Terraform. A description of the required variables can be found in the file `variables.hcl`.
Edit the contents in order to both personalise your gen3 instance and ensure that both
Packer and Terraform will use the correct values for your OpenStack, e.g. you will almost
certainly need to change the values of: `build_image_flavour`, `database_node_flavour` and
`docker_node_flavour` so that appropriate OpenStack Virtual Machine flavours are used.

### Ansible
Ansible requires some of its own variables and these can be created by setting up the
`group_vars/all` by using the template, i.e. `cp group_vars/all.template group_vars/all`
and then updating the contents.
You can modify the ansible `group_vars/all` file to reflect some settings such as:
* *timezone*: This is the time zone setting for all the virtual machines.

## Building the images
Once the variables have been configured (the `build_image_flavour` is probably the most
important as this often varies from system to system) the images can be built. This
can be done with the command:
```shell
$ ./build.sh
```
The script checks for the existence of the target images on OpenStack. If they already
exist, nothing happens. Otherwise, the images are built.

## Deploying with Terraform
The machines are first deployed with terraform. Firstly the environment must be
initialised with `terraform init`. Afterwards `terraform plan` and `terraform apply`
can be used to actually create the infrastructure including: the network and subnetwork;
the security groups; the docker node; the database node.

## Infrastructure Configuration
Finally the infrastructure can be configured using ansible.


