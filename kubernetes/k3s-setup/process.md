## 20220225

[PyratLabs-ansible-K3s-role | Quickstart](https://github.com/PyratLabs/ansible-role-k3s/blob/main/documentation/quickstart-ha-cluster.md)
[How to install Rancher on k3s](https://vmguru.com/2021/04/how-to-install-rancher-on-k3s/)
[Get latest JerStack Cert-Manager manifest for above link](https://github.com/jetstack/cert-manager/releases/)
TODO: Upload swap/security role

``` 
#assumes ubuntu 18.04 or 20.04
#on first Controller node

curl -s https://kube-vip.io/manifests/rbac.yaml > /var/lib/rancher/k3s/server/manifests/kube-vip-rbac.yaml

ctr image pull docker.io/plndr/kube-vip:0.3.2

alias kube-vip="ctr run --rm --net-host docker.io/plndr/kube-vip:0.3.2 vip /kube-vip"

export VIP={chose an open address}

export INTERFACE=ens192

kube-vip manifest daemonset --arp --interface $INTERFACE --address $VIP --controlplane --leaderElection --taint --inCluster | sudo tee /var/lib/rancher/k3s/server/manifests/kube-vip.yaml

#Edit the kube-vip.yaml
      tolerations:
            - effect: NoSchedule
            key: node-role.kubernetes.io/master
            operator: Exists

#Getting the kubectl config:
#Log into the first node, then as root: 
      sudo cat /etc/rancher/k3s/k3s.yaml > /home/ansible/config
#then on my local system: 
      scp ansible@first.node.ip:/home/ansible/config ~/.kube/config

kubectl create namespace cattle-system

kubectl create namespace cert-manager

kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.crds.yaml

helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

helm repo add jetstack https://charts.jetstack.io

helm repo update

#remember to check for latest version of jetstack
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.6.1

kubectl get pods --namespace cert-manager

helm install rancher rancher-latest/rancher --namespace cattle-system --set hostname=k3s-rancher.cluster.local

kubectl -n cattle-system rollout status deploy/rancher

kubectl -n cattle-system get deploy rancher

```

---