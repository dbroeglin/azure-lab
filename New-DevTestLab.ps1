[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [String]
    $ResourceGroupName,

    [String]
    $ResourceGroupLocation = 'West Europe',

    [String]
    $Label = "01",

    [Parameter(Mandatory, ParameterSetName = 'Mail')]
    [String]
    $UserMail,

    [Parameter(Mandatory, ParameterSetName = 'Name')]
    [String]
    $UserName,

    [Parameter(Mandatory)]
    [String]
    $ExistingVnetName,

    [Parameter(Mandatory)]
    [String]
    $ExistingSubnetName
)

$ErrorActionPreference = "stop"

$vmName = "frmps$Label"

New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Force


if ($UserMail) {
    $principalId = Get-AzureRmADUser -Mail $UserMail | Select-Object -ExpandProperty ID 
} else {
    $principalId = Get-AzureRmADUser -SearchString $UserName | Select-Object -ExpandProperty ID      
}
if ($null -eq $principalId) {
    if ($UserMail) {
        throw "Unable to find user with email '$UserMail' in Azure AD"        
    } else {
        throw "Unable to find user with search string '$UserName' in Azure AD"                
    }
}

$vnetId = Get-AzureRmVirtualNetwork | Where-Object Name -eq $ExistingVnetName | Select-object -ExpandProperty ID
if ($null -eq $vnetId) {
    throw "Unable to find existing VNet with name '$ExistingVNetName'"
}

$TemplateParameterObject = @{
    labName                   = "PowerShellLab$Label"
    labVirtualNetworkName     = "lab$Label-vnet"
    existingVirtualNetworkId  = $vnetId.ToString()
    existingSubnetName        = $ExistingSubnetName
    timezoneId                = "W. Europe Standard Time"

    vmName                    = $vmName
    userName                  = "Trainee"
    password                  = "Passw0rd"

    principalId               = $principalId
    roleAssignmentGuid        = New-Guid
}

Write-Verbose "Calling resource group deployment with $($TemplateParameterObject | ConvertTo-Json)"
New-AzureRmResourceGroupDeployment -Name "Deploy_$ResourceGroupName" `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile ARM\dev-test-lab.json `
    -TemplateParameterObject $TemplateParameterObject `
    -Verbose    