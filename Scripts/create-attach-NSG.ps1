<#
.SYNOPSIS
  This script can attach NSG to VM.

.DESCRIPTION
  This script can attach NSG to VM. 

.NOTES
  Version:        1.0
  Author:         Abhishek Roy
  Creation Date:  26.02.2020
#>

[CmdletBinding()]
param
(
    [Parameter(Mandatory=$true)]
    [System.String]$ParametersFile
    
)

#Read parameter file and assign variables
$objParametersFile = Get-Content -Path $ParametersFile | ConvertFrom-Json
[System.String] $ResourceGroupName = $objParametersFile.parameters.RGname[0].value
[System.String] $NICname = $objParametersFile.parameters.NICname[0].value
[System.String] $NSGname  = $objParametersFile.parameters.NSGname[0].value
[System.String] $Location1  = $objParametersFile.parameters.Location1[0].value
[System.String] $RuleName1  = $objParametersFile.parameters.RuleName1[0].value

#Define rule, create NSG and attach rule
$rules = New-AzNetworkSecurityRuleConfig -Name $RuleName1 -Direction Inbound -Priority 1000 -Access Allow -SourceAddressPrefix '*'  -SourcePortRange '*' -DestinationAddressPrefix '*' -DestinationPortRange 3389 -Protocol Tcp 
New-AzNetworkSecurityGroup -Name $NSGname -ResourceGroupName $ResourceGroupName -Location $Location1 -SecurityRules $rules -force

<# Get-AzureRmNetworkSecurityGroup -Name  $NSGname -ResourceGroupName $ResourceGroupName | 
Add-AzNetworkSecurityRuleConfig -Name SQL-rule -Description "Allow SQL connection" -Access 
    Allow -Protocol Tcp -Direction Inbound -Priority 1010 -SourceAddressPrefix *
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 1433 | 
    Set-AzureRmNetworkSecurityGroup

 

Get-AzureRmNetworkSecurityGroup -Name  $NSGname -ResourceGroupName $ResourceGroupName | 
Add-AzNetworkSecurityRuleConfig -Name SQLAG-rule -Description "Allow SQL AG" -Access 
    Allow -Protocol Tcp -Direction Inbound -Priority 1020 -SourceAddressPrefix *
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 5022,6161,6070,445 | 
    Set-AzureRmNetworkSecurityGroup #>
 

#Attach NSG to NIC
$nic = Get-AzNetworkInterface -ResourceGroupName $ResourceGroupName -Name $NICname
$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $NSGname
$nic.NetworkSecurityGroup = $nsg
$nic | Set-AzNetworkInterface
