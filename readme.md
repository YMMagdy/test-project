# Project Details

This readme file is created to document the step by step process of deploying this project from scratch.

## Overview

The following steps are taken to complete this project:

1. Containerizing the flask application in `/app` directory

## Documentation

The following section will be documenting every step on its own and how the final result was produced

### Containerizing the flask application

The following steps were taken to create the `Dockerfile` with non-root user running the container:

1. Used a lightweight version of python3.12 container as a builder
2. Choose the `/app` as my working directory
3. Copied the `app` directory, which has the microservice itself, the `run.py` file to run the application and the requirements.txt file to the directory
4. Copied the `gunicorn` configuration file
5. run `pip install` command with the `--target` to specify the location which the packages will be installed
6. Installed `gunicorn`
7. Remove the `requirements.txt` file
8. Use a lightweight version also of python3.12 for production
9. Put the ENV python path for the python packages to be locatable by the executables
10. Create a group and user called `appuser`
11. Specify the working directory `app`
12. Copy the installed packages to the production image
13. Copy the app directory and all its content
14. Copied gunicorn executable into its location
15. Copied the gunicorn package into its location
16. Change ownership of the app directory to the appuser
17. Expose port 5000
18. The command for starting the container is `gunicorn --config gunicorn_config.py run:app`

The following problems were encountered:

‼️ The application would not start even if the mentioned version of `flask` from the `requirements.txt` is installed

⚠️  Diagnosis: The package that is called `Werkzeug` was not installed

✅ The solution was adding this package to the `requirements.txt` file

---

‼️ Problem: Running `python run.py` will create a single thread to handle requests, which will not be efficient in production.

✅ Solution: Use **`gunicorn`** in production and provide it with the number of workers to handle multiple requests.

---

‼️ The problem was even after the exposing the right port, the application was not accessable from outside the container itself.

⚠️  Diagnosis: The application was only running on `127.0.0.1:5000`, which made it impossible to be accessable from the outside even if port number `5000` was exposed since the requests are all going to be routed to `0.0.0.0:5000`

✅ Solution: Modified `gunicorn_configuration.py` file to bind the application running to the address `0.0.0.0:5000`

---

With this `Dockerfile`, the container became lighter and have less starting time, the container does not run as a root user, which is according to the security best practices, and it can handle more traffic since it runs using `gunicorn` with multiple workers.

### Provision  a Kubernetes Cluster

This section is going to document the Kubernetes Creation using Terraform.

#### Pre Terraform init

Before initializing the backend, we must configure the `azure-cli` in the terminal that is going to run the `terraform init`and `terraform apply`.

The following command should be run before running terraform:

`az login`

This is an interactive login

#### Azure Modules

The following are the modules used in this terraform infrastructure and their Github Links:

1. [Virtual Network Module](https://github.com/Azure/terraform-azurerm-avm-res-network-virtualnetwork) (Later Disposed off since AKS creates its own Virtual Network)
2. [Azure Kubernetes Service](https://registry.terraform.io/modules/Azure/aks/azurerm/latest) (2 versions were tried to create the cluster inside the already created Virtual Network)
3. [Amazon Container Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry) (Gave the AKS role to pull from ACR)
4. Github Access : Added AD Application, Service Principle, Role assignment and OIDC for Github to be able to access all the ACR to push build images.
5. [Hosted Zone and Different Types of Records](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_a_record)
6. NGINX: This was added using Helm to serve as a reverse proxy inside the Kubernetes cluster and to be used as an ingress controller

##### Azure Kubernetes Service

This section is for documenting the AKS module and justify the reason for my choices.

The following are the module's variables, usage and default values:
```

- **default_vm_size**: For the default node pool virtual machine size and this was choosen for being cost efficient with $27 per month per instance
- **default_node_pool_enable_autoscaling**: To enable node horizontal auto-scaling
- **default_node_pool_node_count**: Default number of nodes in the pool
- **default_node_pool_node_max_count**: Maximum number of nodes in the pool and it must be bigger than the *default_node_pool_node_count*
- **default_node_pool_disk_size_in_gb**: Default disk size of each node

```

The following outputs are exported from this module needed for Kubernetes and helm providers authentication:

- **cluster_host_endpoint**
- **client_certificate**
- **cluster_ca_certificate**
- **client_key**

##### Azure Container Registry

This section is for documenting the Azure Container Registry module and justify the reason for my choices.

The following are the module's variables, usage and default values:
```

- **acrs**: A map of objects containing ACR name with its validation to avoid any confusion
- **kubelet_identity**: Needed to give access to the kubernetes cluster to pull images from these ACRs

```

##### GitHub Access

This section is for documenting the GitHub Access module and justify the reason for my choices.

The following are the module's variables, usage and default values:
```

- **gtihub_repo**: The GitHub repository name without the `https://` or `www.` just a plain {USERNAME}/{REPOSITORY_NAME} 
- **github_repo_branch**: The repository's branch that is allowed to have access through OIDC

```

⚠️ Looking back on this module, the map of ACRs are **not a best practice** when we consider security since we are giving access to **multiple ACRs** to a single GitHub repository.

✅ Remove the map of ACRs and use a single ACR. Reuse the module whenever a repository is needed to access an ACR to have a 1:1 relationship between the Github repository and the ACR for **better security** and **providing least privileges**

Steps to give access:

1. Create Azure AD application for Github
2. Create a Service Principle, which is the indentity in the tenant
3. Create the Azure AD OIDC Federation Identity with Github
4. Assign the role of AcrPush to the Github application for each of the ACRs

##### NGINX

Acts as a **reverse proxy** and creates the **ingress class** needed by all the services, which should be exposed outside the cluster.

##### Hosted Zone

This section is for documenting the hosted zone module and justify the reason for my choices.

```

subdomains: Map of objects containing the name, record, type and ttl of each record to be instered as records in the hosted zone
hosted_zone_name: The domain name associated with the hosted zone  

```