#!/bin/bash
set -e

VARIABLES_FILE=gen3.auto.pkrvars.hcl

BASE_IMAGE_NAME=$(grep "^base_image_name" ${VARIABLES_FILE} | sed 's/.*= "\(.*\)"$/\1/')
DATABASE_IMAGE_NAME=$(grep "^database_image_name" ${VARIABLES_FILE} | sed 's/.*= "\(.*\)"$/\1/')
DOCKER_IMAGE_NAME=$(grep "^docker_image_name" ${VARIABLES_FILE} | sed 's/.*= "\(.*\)"$/\1/')

if openstack image show "${BASE_IMAGE_NAME}" &> /dev/null
then
  echo "Openstack image '${BASE_IMAGE_NAME}' found. Not rebuilding."
else
  echo "Openstack image '${BASE_IMAGE_NAME}' not found. Creating…"
  packer build -only="step1.openstack.base_image" .
fi

if openstack image show "${DATABASE_IMAGE_NAME}" &> /dev/null
then
  echo "Openstack image '${DATABASE_IMAGE_NAME}' found. Not rebuilding."
else
  echo "Openstack image '${DATABASE_IMAGE_NAME}' not found. Creating…"
  packer build -only="step2.openstack.database_image" .
fi

if openstack image show "${DOCKER_IMAGE_NAME}" &> /dev/null
then
  echo "Openstack image '${DOCKER_IMAGE_NAME}' found. Not rebuilding."
else
  echo "Openstack image '${DOCKER_IMAGE_NAME}' not found. Creating…"
  packer build -only="step3.openstack.docker_image" .
fi
