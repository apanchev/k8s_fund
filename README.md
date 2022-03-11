# Project description

Everything i'm working on for my Linux Fondation KUBERNETES FUNDAMENTALS (LFS258) course.  
I'm using terraform and Ansible to automate my AWS EC2 configurations.

Link to the course + certification :  
https://training.linuxfoundation.org/training/kubernetes-fundamentals-lfs258-cka-exam-bundle/

# Start the project

Almost automated everything to save time, not required by the course.

### #1 Create terraform var file

Copy-paste the terraform var file and edit it.

```bash
cp terraform/aws.tfvars.sample terraform/aws.tfvars
vim terraform/aws.tfvars
```

### #2 Launch the project
Then just use the automated script.

```bash
./linuxfondation.sh
```
# Other

## Basic node maintenance - upgrade

On CP server:
```bash
sudo apt-cache madison kubeadm
sudo apt-mark unhold kubeadm
sudo apt install kubeadm=xxxxxxx-xxx
sudo apt-mark hold kubeadm
k drain cp --ignore-daemonsets
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply xxxxxx
sudo apt install kubelet=xxxxxxx-xxx kubectl=xxxxxxx-xxx
sudo apt-mark hold kubelet kubectl
```

On workers:
```bash
sudo apt install kubelet=xxxxxxx-xxx kubectl=xxxxxxx-xxx
sudo apt-mark hold kubelet kubectl
```

On every nodes:
```bash
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

## Rollback to a previous replicaset

```bash
k rollout history deploy deployment_name
k rollout undo deploy deployment_name --to-revision 2
```

## Check health of the db using etcd tool

Check the health of the database using the loopback IP and port 2379

```bash
kubectl -n kube-system exec etcd-cp -- sh \
-c "ETCDCTL_API=3 \
ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \
ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt \
ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key \
etcdctl endpoint health -w table"
```

Determine how many databases are part of the cluster. (prod environments must have minimum 5)

```bash
kubectl -n kube-system exec -it etcd-cp -- sh \
-c "ETCDCTL_API=3 \
ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \
ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt \
ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key \
etcdctl member list -w table"
```

Snapshot the etcd database

```bash
kubectl -n kube-system exec -it etcd-cp -- sh \
-c "ETCDCTL_API=3 \
ETCDCTL_CACERT=/etc/kubernetes/pki/etcd/ca.crt \
ETCDCTL_CERT=/etc/kubernetes/pki/etcd/server.crt \
ETCDCTL_KEY=/etc/kubernetes/pki/etcd/server.key \
etcdctl snapshot save ~/snapshot.db"
```