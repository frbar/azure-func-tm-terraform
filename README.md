# Purpose

This repository contains a Terraform template to setup 2 indentical Azure Functions, in 2 different regions

And a simple Azure Function (.NET) project with an Http Trigger.

# Deploy the infrastructure

```powershell
az login

$subscription = "Training Subscription"
az account set --subscription $subscription

$envName = "frbarfunclb" # lowercase, only a-z and 0-9
$location1 = "West Europe"
$location2 = "North Europe"

./terraform.exe -chdir=tf init
./terraform.exe -chdir=tf apply -var "env_name=$($envName)" -var "location1=$($location1)" -var "location2=$($location2)" -auto-approve

```

# Function App
```powershell
remove-item publish\* -recurse -force
dotnet publish src\ -r win-x64 -c Release --self-contained -o publish
Compress-Archive publish\* publish.zip -Force
az functionapp deployment source config-zip --src .\publish.zip -n "$($envName)-func-0" -g "$($envName)-rg"

az functionapp deployment source config-zip --src .\publish.zip -n "$($envName)-func-1" -g "$($envName)-rg"
```

# Tear down

```powershell
az group delete --name "$($envName)-rg"
```