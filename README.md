# PROJECT-MODULE04: Automate Data Pipelines
## Quick Start Instructions

1. Create a IAM user with necessary permissions
2. Create a IAM Role with a trusted policy and the necessary permission sets 
3. Create the variables.tfvars file with number of the deployment accounts
4. Deploy the infraestructure with terraform init, plan, apply
5. For development, you can deploy the apache-airflow environment located in data_dev/src/mwaa with docker compose up --build
6. Import the variables defined in variables.json using the airflow console
7. Create the connection for the amazon redshift serverless, with connection_id=redshift and for aws aws_credentials
8. Execute the dag


---
## Overview

The project sparkify, is made up by the following:

* The terraform IaC code to deploy all the infraestructure of the project
* The apache airflow environment
* The project was tested only with redshift serverless deployed and from a apache airflow environment.

---