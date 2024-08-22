#!/bin/bash

# Set namespace where Argo CD is installed
ARGOCD_NAMESPACE="argo-cd"

# Function to delete a namespace and wait until it is completely removed
delete_namespace() {
    local namespace=$1
    echo "Deleting namespace: $namespace"
    kubectl delete namespace $namespace --ignore-not-found=true
    while kubectl get namespace $namespace &> /dev/null; do
        echo "Waiting for namespace $namespace to be deleted..."
        sleep 2
    done
    echo "Namespace $namespace deleted."
}

# Function to delete a ClusterRoleBinding
delete_clusterrolebinding() {
    local binding=$1
    echo "Deleting ClusterRoleBinding: $binding"
    kubectl delete clusterrolebinding $binding --ignore-not-found=true
}

# Function to delete a ClusterRole
delete_clusterrole() {
    local role=$1
    echo "Deleting ClusterRole: $role"
    kubectl delete clusterrole $role --ignore-not-found=true
}

# Function to delete a ClusterIssuer
delete_clusterissuer() {
    local issuer=$1
    echo "Deleting ClusterIssuer: $issuer"
    kubectl delete clusterissuer $issuer --ignore-not-found=true
}

# Deleting Argo CD namespace and resources
delete_namespace $ARGOCD_NAMESPACE

# Deleting cert-manager namespace and resources (if used)
delete_namespace "cert-manager"

# Deleting ClusterRoleBindings related to Argo CD
delete_clusterrolebinding "argocd-application-controller-cluster-role-binding"

# Deleting ClusterRoles related to Argo CD
delete_clusterrole "argocd-application-controller-cluster-role"

# Deleting ClusterIssuer for cert-manager (if used)
delete_clusterissuer "letsencrypt-prod"

# Deleting any lingering secrets related to Argo CD in all namespaces
echo "Deleting lingering secrets related to Argo CD..."
for secret in $(kubectl get secrets --all-namespaces -o json | jq -r '.items[] | select(.metadata.name | contains("argocd")) | .metadata.namespace + "/" + .metadata.name'); do
    kubectl delete secret $secret --ignore-not-found=true
done

# Deleting any lingering configmaps related to Argo CD in all namespaces
echo "Deleting lingering configmaps related to Argo CD..."
for configmap in $(kubectl get configmaps --all-namespaces -o json | jq -r '.items[] | select(.metadata.name | contains("argocd")) | .metadata.namespace + "/" + .metadata.name'); do
    kubectl delete configmap $configmap --ignore-not-found=true
done

# Final confirmation
echo "Argo CD and all related resources have been deleted."
echo "You can now reinstall Argo CD in a clean environment."

