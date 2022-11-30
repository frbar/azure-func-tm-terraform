# Purpose

This repository contains a Terraform template to setup:
- 2 identical Azure Functions, in 2 different regions
- Traffic Manager
- Cloudflare with wildcard domain
- Cloudflare transform rule to inject x-functions-key

And a simple Azure Function (.NET) project with 2 Http Triggers (`/api/heath` and `/api/hello-world`).

# Deploy infrastructure & code

```powershell
az login

$subscription = "Training Subscription"
az account set --subscription $subscription

# Configuration
$envName = "frbartmpoc" # lowercase, only a-z and 0-9
$location1 = "West Europe"
$location2 = "North Europe"

$env:CF_ZONE_ID    = "xxx"
$env:CF_DOMAIN     = "xxx"

$env:CLOUDFLARE_API_KEY = "xxx"
$env:CLOUDFLARE_EMAIL   = "xxx"

# Provisioning of the infrastructure 

./terraform.exe -chdir=tf init
./terraform.exe -chdir=tf apply -var "env_name=$($envName)" `
                                -var "location1=$($location1)" `
                                -var "location2=$($location2)" `
                                -var "cf_zone_id=$($env:CF_ZONE_ID)" `
                                -var "cf_domain=$($env:CF_DOMAIN)" `
                                -auto-approve

# Build and Deploy of the functions

remove-item publish\* -recurse -force
dotnet publish src\ -c Release -o publish
Compress-Archive publish\* publish.zip -Force
az functionapp deployment source config-zip --src .\publish.zip -n "$($envName)-func-0" -g "$($envName)-rg"

az functionapp deployment source config-zip --src .\publish.zip -n "$($envName)-func-1" -g "$($envName)-rg"

```

# Tear down

```powershell
az group delete --name "$($envName)-rg"
# + manual cleanup in Cloudflare

# or via terraform apply -destroy
```