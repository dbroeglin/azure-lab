[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [String]
    $ResourceGroupName,

    [String]
    $ResourceGroupLocation = 'West Europe',

    [String]
    $Label = "01"
)

$ErrorActionPreference = "stop"

$vmName = "frmps$Label"

New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Force


New-AzureRmResourceGroupDeployment -Name deployDemoLab -ResourceGroupName $ResourceGroupName `
    -TemplateFile ARM\dev-test-lab.json `
    -Verbose `
    -TemplateParameterObject @{
        labName                   = "PowerShellLab01"
        labVirtualNetworkName     = "lab-vnet"
        existingVirtualNetworkId  = "/subscriptions/36ff8855-83cb-4a84-94d7-160128bd6e27/resourceGroups/INFRA/providers/Microsoft.Network/virtualNetworks/common-vnet"
        existingSubnetName        = "default"
        timezoneId                = "W. Europe Standard Time"

        vmName                    = $vmName
        userName                  = "Trainee"
        password                  = "Passw0rd"
    }