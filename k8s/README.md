## Running MongoDB locust workloads in k8s environments

Base kubernetes deployments allow for simple organisation of worker instance scalability. Combining the deployments 
with the ease of scaling the node groups within managed k8s offerings makes it simple to generate even the most 
demanding workloads.

### Base image

The same base image can be used both for master and for worker pods. The actual workload, defined in 
[load_test.py](../load_test.py), can be injected into pods using a configmap. The image has been already built and 
made publicly available for your use. You are currently limited to using the dependencies that are already defined in
the project and the tests can only be defined in [load_test.py](../load_test.py). You can build your own base image
should you require other dependencies or additional files.

### Deployment workflow

Before running deploying your locust workload into k8s, you should make sure that your cluster is addressable through
kubectl. It is advisable to use a cloud provider managed service (EKS, AKS or GKE) for the k8s cluster, as they allow 
for scaling the nodegroups with minimal efforts.

Define your workload in the [load_test.py](../load_test.py) and test in stand-alone mode locally. Set the CLUSTER_URL
in [secret.yaml](secret.yaml), it should also contain your username and password. You can deploy the distributed setup 
into your kubernetes cluster using the following command:

```shell
./redeploy.sh
```

This script will deploy a single pod with locust master and a deployment with three workers. All objects will be 
deployed into your current or default namespace. 

You can also override the task weights in the [worker-deployment.yaml](worker-deployment.yaml) should it be required.
Please make sure your re-deploy the objects after changing the waits. 

### Starting the workload

The following command can be used to forward the 8089 port from the master service to your localhost. This avoids the 
necessity of exposing your master service to the public internet:

```shell
kubectl port-forward service/master 8089:8089
```
Please leave the terminal open for the time that you work with locust. The GUI can be accessed by navigating to 
[http://localhost:8089](http://localhost:8089).

### Scaling the workers

The workers can be scaled up or down by using the following command:
```shell
kubectl scale deployment locust-worker-deployment --replicas 10
```
The --replicas parameter specifies the number of desired worker instances. The kubernetes will automatically spread
the worker pods between all available nodes in the cluster. Make sure you scale your node groups accordingly before
running this command.