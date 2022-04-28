kubectl delete pod locust-master
kubectl delete deployment locust-worker-deployment
kubectl delete svc master
kubectl delete secret mongo-secret
kubectl delete configmap load-file
kubectl delete configmap settings-file


kubectl create configmap load-file --from-file=load_test.py
kubectl create configmap settings-file --from-file=settings.py
kubectl create -f k8s/secret.yaml
kubectl create -f k8s/master.yaml
kubectl create -f k8s/master-service.yaml
kubectl create -f k8s/worker-deployment.yaml
