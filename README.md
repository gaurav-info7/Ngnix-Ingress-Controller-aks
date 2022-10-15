# Ngnix-Ingress-Controller-aks
## Ngnix Ingress Controller for AKS
***


# Main Part - Ngnix Ingress Controller is working with Azure Kubernetes Service (AKS)

## Source Link - https://learn.microsoft.com/en-us/azure/aks/ingress-basic?tabs=azure-cli

***
### $ kubectl create ns ingress-basic
***
## 01 - Create an ingress controller

### Add the ingress-nginx repository

### $ helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
### $ helm repo update
### Use Helm to deploy an NGINX ingress controller
~~~
$ helm install nginx-ingress ingress-nginx/ingress-nginx \
    --version 4.1.3 \
    --namespace ingress-basic \
    --create-namespace \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.admissionWebhooks.patch.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
~~~

### $ kubectl get service --namespace ingress-basic -o wide

~~~
// NAME                                               TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE     SELECTOR
nginx-ingress-ingress-nginx-controller             LoadBalancer   10.0.109.112   20.121.166.235   80:30482/TCP,443:32575/TCP   4m27s  app.kubernetes.io/component=controller,app.kubernetes.io/instance=nginx-ingress,app.kubernetes.io/name=ingress-nginx

nginx-ingress-ingress-nginx-controller-admission   ClusterIP      10.0.90.147    <none>           443/TCP                      4m27s   app.kubernetes.io/component=controller,app.kubernetes.io/instance=nginx-ingress,app.kubernetes.io/name=ingress-nginx
~~~

### $ kubectl get pods --namespace ingress-basic -o wide

~~~
NAME                                                      READY   STATUS    RESTARTS   AGE     IP            NODE                                 NOMINATED NODE   READINESS GATES
nginx-ingress-ingress-nginx-controller-649f4f89df-cxd9f   1/1     Running   0          9m57s   10.244.1.4    aks-workernode-10920729-vmss000000   <none>           <none>
nginx-ingress-ingress-nginx-controller-649f4f89df-w2zst   1/1     Running   0          9m57s   10.244.0.12   aks-agentpool-10920729-vmss000000    <none>           <none>
~~~
***
## 02 - Create an ingress route

### $ vim [hello-world-ingress.yaml](https://github.com/gaurav-info7/Ngnix-Ingress-Controller-aks/blob/main/hello-world-ingress.yaml)

### $ kubectl apply -f hello-world-ingress.yaml --namespace ingress-basic

***
## 03 - Run demo applications

### $ vim [1hellow.yaml](https://github.com/gaurav-info7/Ngnix-Ingress-Controller-aks/blob/main/1hellow.yaml)

### $ vim [2hellow.yaml](https://github.com/gaurav-info7/Ngnix-Ingress-Controller-aks/blob/main/2hellow.yaml)


### $ kubectl apply -f 1hellow.yaml --namespace ingress-basic

### $ kubectl apply -f 2hellow.yaml --namespace ingress-basic

### $ kubectl get service --namespace ingress-basic -o wide

~~~
NAME                                               TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE     SELECTOR
aks-helloworld-one                                 ClusterIP      10.0.227.12    <none>           80/TCP                       15s     app=aks-helloworld-one
aks-helloworld-two                                 ClusterIP      10.0.61.195    <none>           80/TCP                       7s      app=aks-helloworld-two
~~~

### $ kubectl get pods --namespace ingress-basic -o wide

~~~
NAME                                                      READY   STATUS    RESTARTS   AGE     IP            NODE                                 NOMINATED NODE   READINESS GATES
aks-helloworld-one-7b845c75fb-slqjg                       1/1     Running   0          91s     10.244.1.6    aks-workernode-10920729-vmss000000   <none>           <none>
aks-helloworld-two-574fd6f6fb-s6nt5                       1/1     Running   0          83s     10.244.1.7    aks-workernode-10920729-vmss000000   <none>           <none>
~~~
***

## 04 - Test the ingress controller

### App1 on website  
http://{EXTERNAL_IP}

### App2 on website  
http://{EXTERNAL_IP}/hello-world-two

***


