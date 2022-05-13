# eLwazi
Repository for keeping track of eLwazi private openstack gen3 infrastructure and
documentation.

# Setting up the infrastructure on OpenStack using Packer, Terraform and ansible
The infrastructure is managed with a set of scripts that make use of Packer (for creating
the OpenStack virtual machine images that are used), Terraform (for deploying
infrastructure on OpenStack), and finally ansible for configuring the infrastructure.

## Installing software requirements on your machine
You will need to install packer and terraform in addition to setting up a
python virtual environment. Packer and Terraform can be installed by setting up the
appropriate repositories and installing using your OS's package manager. The python
virtual environment is ideally set up using pipenv by running the `pipenv sync`
command. Alternatively ensure you have a python virtual environment with both
the `python-openstackclient` and `ansible` packages installed.

### Initialising packer
It is important to run `packer init base.openstack.pkr.hcl` once in your environment. This
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
The first thing to do is to configure all the variables in your system. A template file
is provided — `variables.pkr.hcl.template`. Create a copy of this named `variables.pkr.hcl`
and edit the contents. The variables to be set are as follows:
* *admin_user*: This is the admin user on your images. For ubuntu-based images this is 
usually `ubuntu`.
* *build_image_flavor*: This is the VM machine flavour that is used when creating the base
images. It can be a very low-spec machine as very little is done here apart from configuring
the initial environment.
* *base_image_source*: This is the starting point for your image. The default we've used
here is pointing to the latest ubuntu 22.04 nightly build, however you can customise this
to an image on your openstack environment (use the image ID).
* *base_image_name*: This is the name the image will be saved as. You can customise this,
however it is advisable to use the same naming scheme for easy identification.
* *database_image_name*: This is the name the database image will be saved as. You can
customise this, however it is advisable to use the same naming scheme for easy
identification.

## Building the base image
Once the variables have been configured (the `build_image_flavour` is probably the most
important as this often varies from system to system) the base image can be built. This
can be done with the command:
```shell
$ packer build -var-file=variables.json base.openstack.pkr.hcl
```

## Building the database image


