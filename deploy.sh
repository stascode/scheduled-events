#/bin/bash

loc=$1
tag=$2
rg=scheduled-events-$loc-$tag
vm1="$tag-$loc-vm1"
vm2="$tag-$loc-vm2"

az group create -n $rg --location $loc
az network vnet create --name vnet1 --resource-group $rg --subnet-name subnet1 --address-prefixes 10.0.0.0/16 --subnet-prefix 10.0.0.0/24 --location $loc
az vm availability-set create --resource-group $rg -l $loc --platform-fault-domain-count 2 --platform-update-domain-count 2 --name avset1

for vm in $vm1 $vm2
do 
	{
	az vm create --resource-group $rg --name $vm --image UbuntuLTS --location $loc --size Standard_D1_v2 --vnet-name vnet1 --subnet subnet1 --public-ip-address publicip-$vm --availability-set avset1
	az vm extension set --resource-group $rg --vm-name $vm \
		--name CustomScript --publisher Microsoft.Azure.Extensions --version 2.0 \
		--protected-settings "{
			\"commandToExecute\": \"STORAGE_ACCOUNT_KEY=$STORAGE_ACCOUNT_KEY bash scheduled_events.sh\",
			\"fileUris\": [
				\"https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/scripts/scheduled_events.py\",
				\"https://${STORAGE_ACCOUNT_NAME}.blob.core.windows.net/scripts/scheduled_events.sh\"
				],
			\"storageAccountName\": \"$STORAGE_ACCOUNT_NAME\",
			\"storageAccountKey\": \"$STORAGE_ACCOUNT_KEY\"
			}"
	} &
done

wait