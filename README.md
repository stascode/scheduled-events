# Quick and dirty sample script to subscribe to Azure VM scheduled events and log those events to a blob storage

Create a storage account 
```bash
az group create --name <rg name> --location eastus
az storage account create --name <storage account name> --location eastus --resource-group <rg name> --sku Standard_LRS
# Get storage account key
az storage account show-connection-string --name <storage account name> --resource-group <rg name>
```

Deploy 2 VMs in AvSet that will subscribe to the scheduled events service:
```bash
STORAGE_ACCOUNT_NAME=<storage account name> STORAGE_ACCOUNT_KEY=<storage account key> ./deploy.sh <azure region> <tag> 
```

For example
```
STORAGE_ACCOUNT_NAME=<storage account name> STORAGE_ACCOUNT_KEY=<storage account key> ./deploy.sh ukwest a1
```