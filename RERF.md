# RERF Setup Documentation

This will go through the initial setup of the RERF docker compose services. The setup consists of setting up docker on an openstack vm and elasticsearch/postgres on a physical server. The databases will need to be setup first so the microservices will work properly. Next you will need to setup openstack for the vm which will hold the docker containers. After openstack is setup it will need to be configured you will need to setup a vm. Once the vm is created you will need to install docker, setup the gen3 configuration and start the commons.


## Installing Databases:

1. Log into the database node
2. Update the services
  sudo apt-get update
3. Install postgres
  sudo apt install postgresql postgresql-contrib
4. Java is needed for elasticsearch so we need to install it then verify it is running
  sudo apt-get update
  sudo apt-get upgrade
  sudo apt-get install default-jre
  java --version
5. Add elasticsearch repo and install it then verify it works by  curl'ing localhost:9200
  wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
  echo "deb https://artifacts.elastic.co/packages/6.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-6.x.list
  sudo apt-get update
  sudo apt-get install elasticsearch
  curl localhost:9200

### Configuring Postgres

Once postgres is installed we will need to configure the database to be used by the microservices. We will first need to update postgres to allow it to be connected to from external locations. Then we will need to create the users and databases the microservices will use.

1. Log into the database node
2. log into postgres user
  sudo su - postgres
3. Update the postgres configuration file to have it listen from everywhere.
  vi /etc/postgresql/10/main/postgresql.conf
4. Update listen_addresses = 'localhost' to listen_addresses = '*'
5. Update the pg_hba.conf file to allow for external connections
  vi /etc/postgresql/10/main/pg_hba.conf
6. Add the following line making sure to update IP range with the subnet of the docker vm
  "host    all             all             (IP range)           md5"
7. Restart postgres
  sudo service postgresql restart
8. Connect to postgres
  psql
9. Create the databases and users.
  ALTER USER postgres WITH PASSWORD '(passowrd)';
  CREATE DATABASE metadata_db;
  CREATE DATABASE fence_db;
  CREATE DATABASE indexd_db;
  CREATE USER fence_user;
  ALTER USER fence_user WITH PASSWORD '(fence_pass)';
  ALTER USER fence_user WITH SUPERUSER;
  CREATE USER peregrine_user;
  ALTER USER peregrine_user WITH PASSWORD '(peregrine_pass)';
  ALTER USER peregrine_user WITH SUPERUSER;
  CREATE USER sheepdog_user;
  ALTER USER sheepdog_user WITH PASSWORD '(sheepdog_pass)';
  ALTER USER sheepdog_user WITH SUPERUSER;
  CREATE USER indexd_user;
  ALTER USER indexd_user WITH PASSWORD '(indexd_pass)';
  ALTER USER indexd_user WITH SUPERUSER;
  CREATE USER arborist_user with PASSWORD '(arborist_pass)';
  ALTER USER arborist_user WITH SUPERUSER;

### Configuring Elasticsearch

After elasticsearch is installed we will need to configure to have external connections, similar to postgres. However, elasticsearch will not have users or databases so we will not need to configure those.

1. Log into database node
2. update elasticsearch configuration
  sudo vi /etc/elasticsearch/elasticsearch.yml
3. Update network.host to the ip of the database node
4. Restart elasticsearch to have changes take effect
  sudo service elasticsearch restart
5. Verify you can connect to it
  curl (database node ip):9200

## Installing Openstack

As openstack is optional and the commons can run without it I will refer to [this](https://docs.openstack.org/devstack/latest/guides/single-machine.html) for setting up openstack. If further support is needed please reach out and I will assist.

## Docker Node Setup

Once you have a node for running the docker containers you will need to download docker, docker-compose and the compose services repo. When that is complete you will need to confiugre the compose services repo. Following that run docker-compose up to start the commons.

1. Log into docker node
2. Update the services
  sudo apt-get upgrade
    note: If using openstack make sure to update dns by running sudo vi /etc/netplan/50-cloud-init.yaml and adding nameservers: addresses: -<dns server ip>
3. Install docker
  sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io
4. Verify docker is running
  docker -v
5. install docker compose
  sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
6. verify docker-compose is running
  docker-compose -v


## Configure Gen3

After docker is setup the microservices configuration will need to be set for docker to spin up the commons. To do this download the base compose-services repo and update it with the necessary information.

1. Log into docker node
2. pull down the compose-services github repo
  git clone https://github.com/uc-cdis/compose-services.git
3. Change directory to the newly downloaded repo.
  cd compose-services
4. Run initial setup script with the ip of the docker node
  bash ./creds_setup.sh (docker node ip)
5. this creates Secrets/ directory which docker uses as configuration files for the microservices we need to update these secrets.
  cd Secrets

### Configure Microsoft Oauth

To use Microsoft as an identity provider we need to first register the app with azure and configure the credentials given within fence-config.

- go to portal.azure.com
- login with Azure credentials
- from menu go to Azure Active Directory
- Manage: App registrations
- + New registration:
    - give it a name
    - Supported Account Types: select middle one: Accounts in any org directory (Any Azure AD directory - Multitenant)
    - Redirect URI: https://(ip addredd)/user/login/microsoft/login (floating IP)
    - Click Certificates and Secrets: add a new secret
        - Expires "Never"
        - click New client secret
        - copy paste the "value" into "client_secret"
        - copy from App registrations (sugita) copy the "client_id" into "client_id"

### fence-config.yaml

The fence-config.yaml file contains information for fence to authenticate users. We will need to point fence to the correct database and give fence the azure credentials so users can use Microsoft as an identity provider.

1. vi fence-config.yaml: change the BASE_UR?L: enter https://<db-IP>/user
    - DB: `postgresql://fence_user:(rerf_fence-password)@(db-IP)/fence_db`
    - under "OPENID_CONNECT": change "google" to "microsoft"
    - add the client_id and secret from Azure
    - change ENABLED IDENTITY PROVIDES "default" from google to microsoft
    - providers: microsoft: name: 'Microsoft Login'
2. Modfiy compose-services "gitops.json"
    - vi gitops.json
    - %s/Case/Subject
    - %s/case/subject

### docker-compose.yml

Because this is a non-standard setup we need to change a few things in the default manifest. First we need to remove all remnants of postgres containers because we are running postgres on a separate physical node. Next we need to update all the database information, credentials/IP, based on what was setup earlier. Then we need to set versions. Latest versions can be found in our [github repo](https://github.com/uc-cdis).

1. vi docker-compose.yml
2. get rid of the postgres block: everything after indexd
3. delete depends_on: postgres
4. under fence-service, get rid of depends_on: postgres
5. under arborist-service:
  environment: PGPASSWORD=(rerf-arborist-password)
  PGHOST=(ip of database node)
6. under peregrine-service:
  change DICTIONARY_URL: to s3 json of rerf_dictionary v 0.0.4, <https://s3.amazonaws.com/dictionary-artifacts/rerf_dictionary/0.0.4/schema.json>
  get rid of "depends_on" - postgres (ONLY) don't remove - sheepdog-service
7. under Sheepdog-service:
  get rid of environment: \n DICTIONARY_URL
  get rid of dependson_on postgres
8. under guppy-service:
  get rid of depends on ES
  changer environemnt: GEN3_ES_ENDPIONT=http://(ip of database node):9200
  get rid of esproxy-service, all lines down to pidgin-service
9. portal-service: gert rid of depends on postgres
10. tube-service
  get rid of dependson: postgres and esproxy,
  change the ES_URL=(ip of database node)
  add the rerf dictionary_url
11. kibana-service:
  change ELASTICSEARCH_URL to IP of the DB node

### compose-service startup scripts

After the docker-compose file is updated there are still some changes that need to be made in the startup scripts, due to the non-standard nature of the deployment using a physical database node.

1. cd ~/compose-services/scripts
2. vi arborist_setup.sh
    - remove everything from `sleep` on
    - change: `psql -U fence_db -H (ip of database node) --password (rerf-fence-password) (the fence password) -c "CREATE ROLE.....`
3. vi fence_setup.sh
    - remove everything from "sleep" up to "echo"
4. vi indexd_setup.sh
    - remove everything from "sleep" up to "echo"
5. sheepdog_setup.sh
    - remove everything from "sleep" up to "echo"
    - change: `python /sheepdog/bin/setup_transactionlogs.py --host (ip of database node) --user sheepdog_user --password (sheepdog_pass) --database metadata_db`
6. vi peregrine_setup.sh
    - remove everything from "sleep" up to "echo"

### Guppy Fix

When first starting the commons we need to update the nginx configuration to remove the guppy block. This is due to guppy not being able to be setup until data is submitted. Guppy uses elasticsearch to query data that has been submitted. However, to get the information in elasticsearch we need to get data and run an etl first. This leads to guppy being unable to startup until data is submitted and the etl is run. To fix this we comment out the guppy block in nginx.

1. Modify nginx
    - vi nginx.conf
    - comment out the guppy block: location /guppy/ ... proxy_pass
        - because can't setup guppy without submitted data; reverse-proxy may not work
        - once data is loaded, we can uncomment, run ETL, and it will work

### Setting Access

Access is set through the user.yaml file. The user.yaml has an rbac section which consists of policies, which correspond to api endpoints, roles, which are tied to the policies and given to users and resources, which correspond to programs/projects. These permisions can be set for specific users in the users block. 

1. cd compose-services
    - vi user.yaml
    - modify the rbac:
        - under `policies:` get rid of the data_upload policy; (keep the workspace policy)
        - under "resources:" get rid of data_file, and get rid of QA/DEV
        - change "jenkins" to "RERF"; change project to "base_mortality_study"
        - leave only workspace_user "roles:"
    - modify the "users:"
        - add user emails
            - give everyone 'workspace' policy only
            - give everyone admin privs in the "RERF" program
            - remove the "auth_id:" except for one for the RERF program

### Starting the Commons

After everything is configured we can start the commons. To do this we need to run docker-compose up -d. The -d flag allows it to run in the background. 

1. docker-compose up -d
2. Verify the services are healthy docker
  docker ps
    - check for unhealthy pods.
    - Note: revproxy may say unhealthy but should be healthy.
3. Test connectivity locally.
  curl localhost:443
    - Ensure you are receiving a response from nginx.
4. Test connectivity in a browser. Enter the node's ip in a web browser.

### Updating the Webpage
TODO

### Running the ETL
TODO

### Updating Versions
TODO
