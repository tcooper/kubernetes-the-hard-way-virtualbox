#!/bin/bash

# Completes the steps from ../docs/03-compute-resources.md with additional
# logic / code to allow steps to be rerun multiple times if wanted / needed.

KUBERNETES_PUBLIC_ADDRESS="192.168.100.100"

printf "\nProvision Compute Resources...\n"
vagrant status | grep -q "not created" && vagrant up
vagrant status

for instance in controller-0 controller-1 controller-2; do
  printf "\nVerification of heartbeat.service for ${instance}...\n"
  vagrant ssh --command "service heartbeat status" "${instance}"
done

printf "\nVerification of VIP for controllers...\n"
if ping -c 3 "${KUBERNETES_PUBLIC_ADDRESS}"
then
  printf "\nTaking Snapshot of Compute Resources...\n"
  vagrant snapshot list | grep -q base && vagrant snapshot delete base
  vagrant snapshot save base
  vagrant snapshot list
else
  printf "\nFixing VIP...\n"
  for instance in controller-2 controller-1; do
    printf "\nStopping heartbeat.service for ${instance}...\n"
    vagrant ssh --command "sudo service heartbeat stop; sudo pkill -u root -f heartbeat" "${instance}"
  done

  if ping -c 1 "${KUBERNETES_PUBLIC_ADDRESS}"
  then
    for instance in controller-2 controller-1; do
      if ping -c 1 "${KUBERNETES_PUBLIC_ADDRESS}"
      then
        printf "\nStarting heartbeat.service for ${instance}...\n"
        vagrant ssh --command "sudo service heartbeat start" "${instance}"
      fi
    done
  fi
fi
