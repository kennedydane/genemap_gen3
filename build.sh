#!/bin/bash
set -e

BASE_IMAGE_NAME=$(grep "^base_image_name" variables.auto.pkrvars.hcl | sed 's/.*= "\(.*\)"$/\1/')
DATABASE_IMAGE_NAME=$(grep "^database_image_name" variables.auto.pkrvars.hcl | sed 's/.*= "\(.*\)"$/\1/')

if openstack image show "${BASE_IMAGE_NAME}" &> /dev/null
then
  echo "Openstack image '${BASE_IMAGE_NAME}' found"
else
  echo "Openstack image '${BASE_IMAGE_NAME}' not found. Creating…"
  packer build -only="step1.openstack.base_image" .
fi

exit 0

if openstack image show "${DATABASE_IMAGE_NAME}" &> /dev/null
then
  echo "Openstack image '${DATABASE_IMAGE_NAME}' found"
else
  echo "Openstack image '${DATABASE_IMAGE_NAME}' not found. Creating…"
  packer build -only="step2.openstack.database_image" .
fi
