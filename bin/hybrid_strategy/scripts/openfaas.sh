#!/usr/bin/bash

## install open
curl -sSL https://cli.openfaas.com | sudo -E sh
# not installing help as it is getting installed in openwhisk 
# this is script is a part of automation . IF you wish to run separately comment below command to install helm
#curl -sSLf https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash

kubectl apply -f https://raw.githubusercontent.com/openfaas/faas-netes/master/namespaces.yml
helm repo add openfaas https://openfaas.github.io/faas-netes/
helm repo update \
 && helm upgrade openfaas --install openfaas/openfaas \
    --namespace openfaas  \
    --set functionNamespace=openfaas-fn \
    --set generateBasicAuth=true

#Verifty openfaas has started
kubectl -n openfaas get deployments -l "release=openfaas, app=openfaas"
PASSWORD=$(kubectl -n openfaas get secret basic-auth -o jsonpath="{.data.basic-auth-password}" | base64 --decode) && \
echo "OpenFaaS admin password: $PASSWORD"

export OPENFAAS_URL=http://127.0.0.1:8080


#Run below commands to 

echo "Run faas-cli command in this terminal for port forwarding"
echo 'kubectl port-forward -n openfaas svc/gateway 8080:8080 &'

#Run commands on new terminal
echo "Run below commands in another terminal to open openfaas GUI"

echo 'export OPENFAAS_URL=http://127.0.0.1:8080'
echo "export PASSWORD=$PASSWORD"
echo 'echo -n \$PASSWORD | faas-cli login -g \$OPENFAAS_URL -u admin --password-stdin'

