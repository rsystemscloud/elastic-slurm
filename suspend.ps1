#!/usr/bin/pwsh
param ($list)

# Set vars
$token = ""
$account = ""
$projid = ""
$vraserver = "api.mgmt.cloud.vmware.com"

# Install PowerVRA if needed
Set-PSRepository -InstallationPolicy Trusted -Name PSGallery
install-module PowerVRA

$data = $list | convertfrom-json
$count = $data.count

# Connect to vRA
$res = Connect-vRAServer -Server $vraserver -APItoken $token

# Get potential deployments
$deployments = Get-vRADeployment | Where-Object {($_.ProjectId -eq $projid) -and ($_.Name -like "SLURM*")}
Write-host "Debug deployments:" $deployments

# Find the VMs
$list = @()
foreach ($deployment in $deployments){
    $resources = Invoke-vRARestMethod -Uri /deployment/api/deployments/$($deployment.id)/resources -Method Get
    foreach ($vm in $data) {
        $tmp = "" | Select-Object resid,deploymentid
        $tmp.resid = $resources.content.properties | Where-Object resourceName -like "*$vm*" | Select-Object -ExpandProperty resourceId
        if ($tmp.resid){
            $tmp.deploymentid = $deployment.id
            $list += $tmp
        }

    }
}
write-host "Debug list:" $list
# Exit if it can't find the VM ids
if (!$list){
    $errormsg =  "errormsg: Could not find the VMs"
    return $errormsg
    exit 1
}

$deploymentids = $list.deploymentid | Select-Object -Unique
#write-host "Debug deploymentids:" $deploymentids

foreach ($deploymentid in $deploymentids){
    # Get all VMs in the deployment
    $vms = (Invoke-vRARestMethod -Uri /deployment/api/deployments/$deploymentid/resources -Method Get).content
    $vms = $vms | Where-Object type -eq "Cloud.vSphere.Machine"
    $vmcount = ($list | Where-Object deploymentid -eq $deploymentid).count
    # If deleting all VMs in the deployment, just delete the deployment
    if ($vms.count -eq $vmcount) {
        $res = Invoke-vRARestMethod -Uri /deployment/api/deployments/$deploymentid -Method Delete
        write-host $res
    }

    #Delete the VMs
    else {
        foreach ($resid in $list) {write-host "resid is $resid and deploymentid is $deploymentid"}
        $resids = $list | where-object deploymentid -eq "$deploymentid" | select-object -ExpandProperty resid
        foreach ($resid in $resids){
            $res = Invoke-vRARestMethod -Uri /deployment/api/deployments/$deploymentid/resources/$resid -Method Delete
            write-host $res
        }
    }
}
