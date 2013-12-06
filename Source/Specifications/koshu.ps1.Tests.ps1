$here			= Split-Path -Parent $MyInvocation.MyCommand.Path
$koshuDir		= "$here\..\Koshu"

. "$koshuDir\koshu-helpers.ps1"

Describe "koshu.ps1" {

	$source			= "$koshuDir\Templates\koshu.ps1"
	$destination	= "$TestDrive\koshu.ps1"
	$version		= "0.6.0"
	$packagesDir	= ".\Source\Packages"
	
	Context "when nuget.exe is found in subdirectory" {

		scaffold_koshufile $source $destination $version $packagesDir
		Set-Content -Value "properties {}; task default -depends doit; task doit {};" -Path "$TestDrive\build.ps1"
		
		$nugetSource = "C:\Nuget-Console\NuGet.exe"
		$nugetDestinationDir = "$TestDrive\Source\.nuget"
		$nugetDestination = "$nugetDestinationDir\NuGet.exe"
		(New-Item $nugetDestinationDir -Type directory -Force)
		(New-Object System.Net.WebClient).DownloadFile($nugetSource, $nugetDestination)
		
		$currentDir = Get-Location
		Set-Location $TestDrive
		
		.$destination build doit
		
		Set-Location $currentDir
        
		It "restores koshu and psake nuget packages" {
			(test-path "$TestDrive\Source\Packages\Koshu.$version").should.be($true)
		}
		
    }
	
	Context "when nuget is in the path" {
	
		if ($env:Path.Contains("c:\Nuget-Console\;") -eq $false) {
			Write-Host "Adding nuget to path" -Fore yellow
			$env:Path = $env:Path.TrimEnd(';')
			$env:Path = $env:Path + ";c:\Nuget-Console\;"
		}
		
		scaffold_koshufile $source $destination $version $packagesDir
		Set-Content -Value "properties {}; task default -depends doit; task doit {};" -Path "$TestDrive\build.ps1"
		
		$currentDir = Get-Location
		Set-Location $TestDrive
		
		.$destination build doit
		
		Set-Location $currentDir
        
		It "restores koshu and psake nuget packages" {
			(test-path "$TestDrive\Source\Packages\Koshu.$version").should.be($true)
		}
		
    }

}