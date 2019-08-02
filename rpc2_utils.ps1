
#
#
#
Install-Module -Name Posh-SSH
Install-Module -Name Await

##
#  Requires full PowerShell 3.0 as Core is unsupported.
#
if ($PSVersionTable.PSCompatibleVersions -contains '3.0') -and ($PSVersionTable.PSEdition -ne 'Core') {

	# Detect & Install Required Modules
	# TODO: Detect modules.
	# TODO: Fail if modules do not load.
	Install-Module -Name Posh-SSH
	Install-Module -Name Await

	New-SSHSession -ComputerName TargetDevice -Credential (Get-Credential)

}