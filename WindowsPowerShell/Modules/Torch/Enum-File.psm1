function Enum-File {
<#
.SYNOPSIS
Searches the file system of remote systems for specific files and returns the file's location.

.DESCRIPTION
This commandlet uses Windows Remote Management to collect Windows file system information from remote systems.

Specify computers by name or IP address.

Use the -Verbose switch to see detailed information.

.PARAMETER TargetList 
Specify host(s) to retrieve data from.

.PARAMETER ConfirmTargets
Verify that targets exist in the network before attempting to retrieve data.

.PARAMETER ThrottleLimit 
Specify maximum number of simultaneous connections.

.PARAMETER Directory
When specified, determines the directory where the search begins.  By default, it starts at c:\.

.PARAMETER File 
When specified, determines the file, or keyword, to search.

.PARAMETER Recurse
When specified, enables searching through the file system recursively.

.PARAMETER CSV 
Specify path to output file, output is formatted as comma separated values.

.PARAMETER TXT 
Specify path to output file, output formatted as text.

.EXAMPLE
The following example gets a list of computer names from the pipe and writes output to a text file.

PS C:\> Enum-File -TargetList $Targs -File notepad.exe -Directory C:\Users\jsmith\Downloads -TXT C:\pathto\output.txt

.EXAMPLE
The following example specifies one computername and sends output to a comma-separated-value file (csv).

PS C:\> Enum-File -TargetList Server01 -File notepad.exe -Directory C:\Users\jsmith\Downloads -CSV C:\pathto\output.csv

.EXAMPLE
The following example specifies one computername and recursively searches the directory C:\Users\jsmith for the keyword "cmd".

PS C:\> Enum-File -TargetList Server01 -Recurse -Directory C:\Users\jsmith -File cmd

.NOTES
Version: 3.0.0915
Author : Jared "Huck" Atkinson, Ryan "Candy" Rickert
Cleaned by RBOT Sep 15

.INPUTS

.OUTPUTS

.LINK
#>
[CmdLetBinding(SupportsShouldProcess=$false)]
    Param(
        [Parameter()]
        [String[]]$TargetList,
        
        [Parameter()]
        [Switch]$ConfirmTargets,

        [Parameter()]
        [Int]$ThrottleLimit = 10,

        [Parameter(Mandatory = $True)]
        [String]$Directory = 'C:\',

        [Parameter(Mandatory = $True)]
        [String]$File,

        [Parameter()]
        [Switch]$Recurse,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]$CSV,
		
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]$TXT
    )
    if($PSBoundParameters['CSV']) { $OutputFilePath = (Resolve-Path (Split-Path $CSV -Parent)).Path + '\' + (Split-Path $CSV -Leaf) }
    elseif($PSBoundParameters['TXT']) { $OutputFilePath = (Resolve-Path (Split-Path $TXT -Parent)).Path + '\' + (Split-Path $TXT -Leaf) }

    $ScriptTime = [Diagnostics.Stopwatch]::StartNew()
    $ErrorFileHosts,$ErrorFileVerbose = Set-ErrorFiles -ModuleName Enum-File
        
    $Global:Error.Clear()
    $RemoteScriptBlock = {
        Param([String]$Directory, [String]$File, [Bool]$Recurse)

        $StartTime = [DateTime]::Now
                
        if ($Recurse) { $FileNames = Invoke-Expression "cmd.exe /c dir /b /s /ah /as /a-d $Directory 2>&1 | findstr /i $File 2>&1" }
        else { $FileNames = Invoke-Expression "cmd.exe /c dir /b /ah /as /a-d $Directory 2>&1 | findstr /i $File 2>&1" }

        $Skipped = 0
        foreach($Name in $FileNames){
            if ($Name -like '*Application Data\Application Data*') {
                $Skipped++
                Write-Verbose "Skipped $Name"
            }
            else {
                $obj = New-Object -TypeName PSObject
                
                $obj | Add-Member -MemberType NoteProperty -Name TIME -Value $StartTime 
        		$obj | Add-Member -MemberType NoteProperty -Name FILENAME -Value $Name 
        		$obj | Add-Member -MemberType NoteProperty -Name SEARCHPARAM -Value $File
                Write-Output $obj
            }
        }                
    }#End RemoteScriptblock
        
    if ($PSBoundParameters['TargetList']) {
        if ($ConfirmTargets.IsPresent) { $TargetList = Confirm-Targets $TargetList }        
        
        $ReturnedObjects = New-Object Collections.ArrayList
        $HostsRemaining = [Collections.ArrayList]$TargetList
        Write-Progress -Activity 'Waiting for jobs to complete...' -Status "Hosts Remaining: $($HostsRemaining.Count)" -PercentComplete (($TargetList.Count - $HostsRemaining.Count) / $TargetList.Count * 100)

        Invoke-Command -ComputerName $TargetList -ScriptBlock $RemoteScriptBlock -SessionOption (New-PSSessionOption -NoMachineProfile) -ThrottleLimit $ThrottleLimit |
        ForEach-Object { 
            if ($HostsRemaining -contains $_.PSComputerName) { $HostsRemaining.Remove($_.PSComputerName) }
            [void]$ReturnedObjects.Add($_)
            Write-Progress -Activity 'Waiting for jobs to complete...' -Status "Hosts Remaining: $($HostsRemaining.Count)" -PercentComplete (($TargetList.Count - $HostsRemaining.Count) / $TargetList.Count * 100)
        }
        Write-Progress -Activity 'Waiting for jobs to complete...' -Status 'Completed' -Completed
    }

    Get-ErrorHost -ErrorFileVerbose $ErrorFileVerbose -ErrorFileHosts $ErrorFileHosts

    if ($ReturnedObjects -ne $null) {
        if ($PSBoundParameters['CSV']) { $ReturnedObjects | Export-Csv -Path $OutputFilePath -Append -NoTypeInformation -ErrorAction SilentlyContinue }
        elseif ($PSBoundParameters['TXT']) { $ReturnedObjects | Out-File -FilePath $OutputFilePath -Append -ErrorAction SilentlyContinue }
        else { Write-Output $ReturnedObjects }
    }

    [GC]::Collect()
    $ScriptTime.Stop()
    Write-Verbose "Done, execution time: $($ScriptTime.Elapsed)"
}