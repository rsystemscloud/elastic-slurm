#!/usr/bin/pwsh
param ($nodelist)

# Set vars
$token = ""
$account = ""
$projid = ""
$blueprintid = ""
$vraserver = "api.mgmt.cloud.vmware.com"

# Install PowerVRA if needed
Set-PSRepository -InstallationPolicy Trusted -Name PSGallery
install-module PowerVRA

$nodes = /usr/bin/scontrol show hostnames $nodelist
$count = $nodes.count
$list = $nodes | convertto-json
if ($count -eq 1) {
    $list = @"
    ["$nodes"]
"@
}

write-host "Debug vars:" $list
write-host "Debug count:" $count

# Connect to vRA
$res = Connect-vRAServer -Server $vraserver -APItoken $token
#Write-host "Debug Connect-vRA Server" $res


# This is unix timestamp in seconds, to use in the name of the deployment
$timestamp = Get-Date -UFormat %s

# Account here can be hard coded, since it's always AWS Truepower
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
write-host "Debug json:" $body
$res = Invoke-vRARestMethod -Method Post -URI "/catalog/api/items/$blueprintid/request" -Body $body
return $res
