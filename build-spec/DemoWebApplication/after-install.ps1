# CodeDeploy runs PowerShell(x86) and we need PowerShell(x64)
# Reference: https://docs.aws.amazon.com/codedeploy/latest/userguide/troubleshooting-deployments.html#troubleshooting-deployments-powershell

# Swap to PowerShell(x64)
 # Import the WebAdministration module if it is not loaded
		 If ((Get-Module | Where Name -eq WebAdministration) -eq $null) {
			Import-Module WebAdministration -ErrorAction Stop
		 }
		 
If ($PSHOME -like "*SysWOW64*") {
  Write-Warning "Restarting this script under 64-bit Windows PowerShell."

  & (Join-Path ($PSHOME -replace "SysWOW64", "SysNative") powershell.exe) -File (Join-Path $PSScriptRoot $MyInvocation.MyCommand) @args

  Exit $LastExitCode

  # Was restart successful?
    Write-Warning "Hello from $PSHOME"
    Write-Warning "  (\SysWOW64\ = 32-bit mode, \System32\ = 64-bit mode)"
    Write-Warning "Original arguments (if any): $args"
}

# Do the actual work
Try {
		$envexists = [System.Environment]::GetEnvironmentVariable('CONNECT', 'Machine')
		if($envexists -eq $null){
			if($env:computername.Contains("QA")){
					[Environment]::SetEnvironmentVariable("CONNECT", "QA", [System.EnvironmentVariableTarget]::Machine)
			}
			elseif($env:computername.Contains("STG")){
					[Environment]::SetEnvironmentVariable("CONNECT", "STG", [System.EnvironmentVariableTarget]::Machine)
			}
			elseif($env:computername.Contains("BUR")){
					[Environment]::SetEnvironmentVariable("CONNECT", "PROD", [System.EnvironmentVariableTarget]::Machine)
			}
			else{
					[Environment]::SetEnvironmentVariable("CONNECT", "DEV", [System.EnvironmentVariableTarget]::Machine)
			}
		}
		$env = [System.Environment]::GetEnvironmentVariable('CONNECT', 'Machine')
		$LocalStage    = 'D:\inetpub\Login'
		$webConfigFile = Join-Path -Path $LocalStage -ChildPath 'Web.config'
		if($env -ne 'DEV'){
			$envConfigFile = Join-Path -Path $LocalStage -ChildPath ('Web.{0}.config' -f $env)
		}
		# $envDeleteQAConfig  = Join-Path -Path $LocalStage -ChildPath 'Web.QA.config'
		# $envDeleteSTGConfig = Join-Path -Path $LocalStage -ChildPath 'Web.STG.config'
		# $envDeletePRODConfig = Join-Path -Path $LocalStage -ChildPath 'Web.PROD.config'
		
		# If($env -ne 'DEV'){
			# # delete the current web.config file if found
			# if (Test-Path -Path $webConfigFile -PathType Leaf) {
				# Write-Host "Old web config exists, Deleting the same"
				# Remove-Item -Path $webConfigFile -Force
			
				# # make a copy of the wanted environment config file and name that web.config
				# Copy-Item -Path $envConfigFile -Destination $webConfigFile
			# }
		# }
				# Remove-Item $envDeleteQAConfig -Force
				# Remove-Item $envDeleteSTGConfig -Force
				# Remove-Item $envDeletePRODConfig -Force
				Write-Host "Web config stage is completed" -ForegroundColor Green
		
		
		 # Take action on the application pool
		 Get-ChildItem -Path IIS:\AppPools -ErrorAction Stop | Where Name -eq "Login" | Start-WebAppPool -ErrorAction Stop
}
Catch {
    Throw $_
}