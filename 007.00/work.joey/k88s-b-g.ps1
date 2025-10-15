# open VS Code, Terminal > New Terminal
$ns = "bg-lab"
kubectl create namespace $ns
kubectl config set-context --current --namespace=$ns
kubectl version --short
kubectl get nodes
