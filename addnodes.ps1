#!/usr/bin/pwsh
param ($list)
$count = ($list | convertfrom-json).count

# Set vars
$account = ""
$projid = ""
$blueprintid = ""
$token = ""
$vraserver = "api.mgmt.cloud.vmware.com"

# Connect to vRA
$res = Connect-vRAServer -Server $vraserver -APItoken $token


# This is unix timestamp in seconds, to use in the name of the deployment
$timestamp = Get-Date -UFormat %s
$name = "SLURM Created $timestamp-$account"

# Build the request
$body = @"
{
  "deploymentName": "$name",
  "inputs":  {
    "computeCount": $count,
    "names":$list
    },
  "projectId": "$projid"
}
"@
$res = Invoke-vRARestMethod -Method Post -URI "/catalog/api/items/$blueprintid/request" -Body $body
return $res
