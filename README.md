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
