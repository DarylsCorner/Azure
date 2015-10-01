workflow Start-ARMVM
{

	$AssetCred = 'Admin'
	$Cred = Get-AutomationPSCredential -Name $AssetCred
	$NULL = Add-AzureAccount -Credential $Cred
	$Subscr = Get-AutomationVariable 'ActiveSubscription'
	$NULL  = Select-AzureSubscription -SubscriptionName $Subscr	
	$RGName = Get-AutomationVariable 'RGvariable'
	Write-Output "Active subscription is: $Subscr"
	Write-Output "RG Name is: $RGName"
	
	InlineScript
	{
			
		$VMs = Get-AzureResource -ResourceGroupName $using:RGName -ResourceType "Microsoft.Compute/VirtualMachines" -OutputObjectFormat New | 
		Get-AzureVM -Status | Select-Object Name, @{n="Status";e={$_.Statuses[-1].DisplayStatus}}
		
		ForEach ($VM in $VMs)
		{
			If ($VM.Status -eq "VM deallocated")
			{
				
				Write-Output "Starting VM $($VM.Name)"
				$NULL = Start-AzureVM -ResourceGroupName $using:RGName -Name $VM.Name
				
				do
				{
				
					Write-Output "Sleeping for 5 Seconds!!"
					Start-Sleep -Seconds 5
										
				}While ($VM.Status -ne "VM deallocated")
				
			}
			
			Else
			{
			
				Write-Output "VM $($VM.Name) is in running state, skipping this VM!!"
			
			}
		}
	}
	
}