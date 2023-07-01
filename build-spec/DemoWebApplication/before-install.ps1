# CodeDeploy runs PowerShell(x86) and we need PowerShell(x64)
# Reference: https://docs.aws.amazon.com/codedeploy/latest/userguide/troubleshooting-deployments.html#troubleshooting-deployments-powershell

# Swap to PowerShell(x64)
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
     # Import the WebAdministration module if it is not loaded
     If ((Get-Module | Where Name -eq WebAdministration) -eq $null) {
         Import-Module WebAdministration -ErrorAction Stop
     }
     # Take action on the application pool
     Get-ChildItem -Path IIS:\AppPools -ErrorAction Stop | Where Name -eq "Login" | Stop-WebAppPool -ErrorAction Stop
     # Wait for the application pool to transistion (should implement controled loop)
     Start-Sleep -Seconds 30
     # Clear the code directory
     Remove-Item "D:\inetpub\Login\*" -Recurse -Force
}
Catch {
    Throw $_
}