Param(
	[Parameter(Position=0,Mandatory=1)] [string]$buildFile,
	[Parameter(Position=1,Mandatory=1)] [string]$target
)

# Ensure errors fail the build
$ErrorActionPreference = 'Stop'

# Restore koshu nuget package
$nuget = (Get-ChildItem -Path . -Filter NuGet.exe -Recurse | Select-Object -First 1)
if ($nuget) { $nuget = $nuget.FullName } else { $nuget = "NuGet.exe" }
try {
	& $nuget install Koshu -version #Version# -outputdirectory "#PackagesPath#"
} catch [System.Management.Automation.CommandNotFoundException] {
	throw 'Could not find NuGet.exe and it does not seem to be in your path! Aborting build.'
}

# Initialize koshu
#PackagesPath#\Koshu.#Version#\tools\init.ps1

# Trigger koshu
Koshu-Build $buildFile $target