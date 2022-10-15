

Main Part - Ngnix Ingress Controller is working with Azure Kubernetes Service (AKS)

Source Link - https://learn.microsoft.com/en-us/azure/aks/ingress-basic?tabs=azure-cli


$ kubectl create ns ingress-basic

>>> Create an ingress controller

>> Add the ingress-nginx repository
# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
# helm repo update

# Use Helm to deploy an NGINX ingress controller
# helm install nginx-ingress ingress-nginx/ingress-nginx \
    --version 4.1.3 \
    --namespace ingress-basic \
    --create-namespace \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.admissionWebhooks.patch.nodeSelector."kubernetes\.io/os"=linux \
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
 

# kubectl get service --namespace ingress-basic -o wide

NAME                                               TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE     SELECTOR
nginx-ingress-ingress-nginx-controller             LoadBalancer   10.0.109.112   20.121.166.235   80:30482/TCP,443:32575/TCP   4m27s  app.kubernetes.io/component=controller,app.kubernetes.io/instance=nginx-ingress,app.kubernetes.io/name=ingress-nginx

nginx-ingress-ingress-nginx-controller-admission   ClusterIP      10.0.90.147    <none>           443/TCP                      4m27s   app.kubernetes.io/component=controller,app.kubernetes.io/instance=nginx-ingress,app.kubernetes.io/name=ingress-nginx

# kubectl get pods --namespace ingress-basic -o wide

NAME                                                      READY   STATUS    RESTARTS   AGE     IP            NODE                                 NOMINATED NODE   READINESS GATES
nginx-ingress-ingress-nginx-controller-649f4f89df-cxd9f   1/1     Running   0          9m57s   10.244.1.4    aks-workernode-10920729-vmss000000   <none>           <none>
nginx-ingress-ingress-nginx-controller-649f4f89df-w2zst   1/1     Running   0          9m57s   10.244.0.12   aks-agentpool-10920729-vmss000000    <none>           <none>


>> Run demo applications

# vim 1hellow.yaml

-----------------------------------------------------
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aks-helloworld-one  
spec:
  replicas: 1
  selector:
    matchLabels:
      app: aks-helloworld-one
  template:
    metadata:
      labels:
        app: aks-helloworld-one
    spec:
      containers:
      - name: aks-helloworld-one
        image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
        ports:
        - containerPort: 80
        env:
        - name: TITLE
          value: "Welcome to Azure Kubernetes Service (AKS)"
---
apiVersion: v1
kind: Service
metadata:
  name: aks-helloworld-one  
spec:
  type: ClusterIP
  ports:
  - port: 80
  selector:
    app: aks-helloworld-one
-----------------------------------------------------



# vim 2hellow.yaml

-----------------------------------------------------

apiVersion: apps/v1
kind: Deployment
metadata:
  name: aks-helloworld-two  
spec:
  replicas: 1
  selector:
    matchLabels:
      app: aks-helloworld-two
  template:
    metadata:
      labels:
        app: aks-helloworld-two
    spec:
      containers:
      - name: aks-helloworld-two
        image: mcr.microsoft.com/azuredocs/aks-helloworld:v1
        ports:
        - containerPort: 80
        env:
        - name: TITLE
          value: "AKS Ingress Demo"
---
apiVersion: v1
kind: Service
metadata:
  name: aks-helloworld-two  
spec:
  type: ClusterIP
  ports:
  - port: 80
  selector:
    app: aks-helloworld-two

-----------------------------------------------------

# kubectl apply -f 1hellow.yaml --namespace ingress-basic

# kubectl apply -f 2hellow.yaml --namespace ingress-basic

# kubectl get service --namespace ingress-basic -o wide

NAME                                               TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE     SELECTOR
aks-helloworld-one                                 ClusterIP      10.0.227.12    <none>           80/TCP                       15s     app=aks-helloworld-one
aks-helloworld-two                                 ClusterIP      10.0.61.195    <none>           80/TCP                       7s      app=aks-helloworld-two




# kubectl get pods --namespace ingress-basic -o wide

NAME                                                      READY   STATUS    RESTARTS   AGE     IP            NODE                                 NOMINATED NODE   READINESS GATES
aks-helloworld-one-7b845c75fb-slqjg                       1/1     Running   0          91s     10.244.1.6    aks-workernode-10920729-vmss000000   <none>           <none>
aks-helloworld-two-574fd6f6fb-s6nt5                       1/1     Running   0          83s     10.244.1.7    aks-workernode-10920729-vmss000000   <none>           <none>


>>> Create an ingress route

# vim hello-world-ingress.yaml

-----------------------------------------------------
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-world-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /hello-world-one(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: aks-helloworld-one
            port:
              number: 80
      - path: /hello-world-two(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: aks-helloworld-two
            port:
              number: 80
      - path: /(.*)
        pathType: Prefix
        backend:
          service:
            name: aks-helloworld-one
            port:
              number: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-world-ingress-static
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/rewrite-target: /static/$2
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /static(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: aks-helloworld-one
            port: 
              number: 80

-----------------------------------------------------

# kubectl apply -f hello-world-ingress.yaml --namespace ingress-basic



>>> Test the ingress controller

>> App1 on website  
http://{EXTERNAL_IP}

>> App2 on website  
http://{EXTERNAL_IP}/hello-world-two





