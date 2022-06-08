## How to setup

1. [Install Terraform CLI ](https://learn.hashicorp.com/tutorials/terraform/install-cli) following the offical documentation
2. Create _terraform.tfvars_ within the terraform(terraform) directory. For this copy _terraform.tfvars.template_, fill in your required paramters and rename the file to _terraform.tfvars_.
   When testing with an existing MongoDB Cluster ensure to provide the full connection string at _connectionString_ including write concern and username & password
3. Open a terminal within the cloud provider directory
4. Run

```shell
terraform init
terraform apply
./run_locust.sh
```

Read the Locust dashboard URL from the console output 5. **Important:** After testing run `terraform destroy` to terminate all created resources

## Start Locust

To start Locust run `./run_locust.sh` and copy the Locust dashboard URL from the output.
Use `./kill_locust.sh` to stop the locust processes running on the workers and `./kill_locust all` to also stop the process on the master.
Afterwards, `./run_locust.sh` can be used to restart all processes.
`./run_locust.sh` will always resync _load_test.py_ and related files from your machine to the Locust primary and workers.
Alternatively, you can provide custom values for the variable _locustFiles_ which will copy files within the root directory will be copied.
