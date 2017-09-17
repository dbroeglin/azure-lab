[CmdletBinding()]
Param(
    [Parameter(Mandatory)]
    [String]
    $ResourceGroupName
)

$ErrorActionPreference = "Stop"

# Remove the Lab first to avoid locking issues with the resource group
Get-AzureRmResource -ResourceGroupName $ResourceGroupName -ResourceType microsoft.devtestlab/labs |
    Remove-AzureRmResource -Force:$Force

Remove-AzureRmResourceGroup -Name $ResourceGroupName -Force:$Force