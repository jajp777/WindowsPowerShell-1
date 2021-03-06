#
# Module manifest for module 'Torch'
#
# Generated by: Jesse "RBOT" Davis
#
# Generated on: 8/31/2015
#

@{

# Script module or binary module file associated with this manifest.
# RootModule = ''

# Version number of this module.
ModuleVersion = '1.0'

# ID used to uniquely identify this module
GUID = 'b11f1921-3622-41d7-859d-49a6601d8722'

# Author of this module
Author = 'Jesse Davis'

# Company or vendor of this module
CompanyName = '92 IOS'

# Copyright statement for this module
#Copyright = ''
 
# Description of the functionality provided by this module
Description = 'Host-based scripts for enumeration and discovery.'
 
# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '2.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @('.\Close-TcpConnection.psm1',
               '.\Enum-Adapter.psm1', 
               '.\Enum-AutoRun.psm1', 
               '.\Enum-Driver.psm1', 
               '.\Enum-File.psm1', 
               '.\Enum-Logon.psm1', 
               '.\Enum-Pipe.psm1', 
               '.\Enum-Process.psm1', 
               '.\Enum-Service.psm1',  
               '.\Export-MFT.psm1', 
               '.\Get-FileHash.psm1',
               '.\Get-MFT.psm1',  
               '.\Get-Netstat.psm1', 
               '.\Get-ProcessModules.psm1', 
               '.\Get-ProcessTrace.psm1', 
               '.\Get-SchTasks.psm1', 
               '.\Get-SkullEvent.psm1',
               '.\Invoke-HostScans.psm1', 
               '.\Invoke-HostSOP.psm1', 
               '.\Invoke-SkullExec.psm1', 
               '.\Search-FileHash.psm1', 
               '.\Stop-Thread.psm1', 
               '.\Torch.psm1')

# Functions to export from this module
FunctionsToExport = '*'

# Cmdlets to export from this module
CmdletsToExport = '*'

# Variables to export from this module
VariablesToExport = '*'

# Aliases to export from this module
AliasesToExport = '*'

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess
# PrivateData = ''

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
