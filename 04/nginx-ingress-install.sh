#!/bin/bash

kubectl apply -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/v5.3.1/deployments/common/ns-and-sa.yaml

kubectl apply -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/v5.3.1/deployments/rbac/rbac.yaml

kubectl apply -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/v5.3.1/deployments/common/nginx-config.yaml

kubectl apply -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/v5.3.1/deployments/common/ingress-class.yaml

kubectl apply -f https://raw.githubusercontent.com/nginx/kubernetes-ingress/v5.3.1/deploy/crds.yaml

kubectl apply -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/v5.3.1/deployments/deployment/nginx-ingress.yaml

kubectl apply -f https://raw.githubusercontent.com/nginxinc/kubernetes-ingress/v5.3.1/deployments/service/loadbalancer.yaml