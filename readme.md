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
