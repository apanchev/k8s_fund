#!/bin/bash
PS3='
Choose what to do: '
choices=("Start the project" "Destroy intances" "Launch Ansible config")
select choice in "${choices[@]}"; do
  case $choice in
    "Start the project")
      cd terraform
      terraform init
      terraform plan -var-file aws.tfvars
      terraform apply -var-file aws.tfvars
      cd ../ansible
      i=1
      sp="/-\|"
      counter=0
      printf "Waiting for AWS instances to be available ...  "
      until [ $counter -gt 500000 ]
      do
        printf "\b${sp:i++%${#sp}:1}"
        ((counter++))
      done
      ansible-playbook -i ansible_hosts ansible_playbook_config.yml
      exit
      ;;
    "Destroy intances")
      cd terraform
      terraform apply -destroy -var-file aws.tfvars
      exit
      ;;
    "Launch Ansible config")
      cd ansible
      ansible-playbook -i ansible_hosts ansible_playbook_config.yml
      exit
      ;;
    *) echo "Invalid option please select between 1 and 2";;
  esac
done