function Enum-Pipe {
<#
.SYNOPSIS
Enumerates named pipes on a remote host

.DESCRIPTION
Enum-Pipe will reach out to a remote host and query currently existing named pipes.

.PARAMETER TargetList 
Specify host(s) to retrieve data from.

.PARAMETER ConfirmTargets
Verify that targets exist in the network before attempting to retrieve data.

.PARAMETER ThrottleLimit 
Specify maximum number of simultaneous connections.

.PARAMETER Timeout 
Specify timeout length, defaults to 3 seconds.

.PARAMETER CSV 
Specify path to output file, output is formatted as comma separated values.

.PARAMETER TXT 
Specify path to output file, output formatted as text.

.EXAMPLE
PS C:\> New-TargetList -Cidr 10.10.20.0/24 | Enum-Pipe

.NOTES
Version: 3.0
Author : Jared "Huck" Atkinson
Cleaned by RBOT Sep 15

.INPUTS

.OUTPUTS

.LINK
#>
[CmdLetBinding(SupportsShouldProcess = $false)]
    Param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String[]]$TargetList,

        [Parameter()]
        [Switch]$ConfirmTargets,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Int]$ThrottleLimit = 10,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]$CSV,
		
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [String]$TXT
    ) #End Param

    if($PSBoundParameters['CSV']) { $OutputFilePath = (Resolve-Path (Split-Path $CSV -Parent)).Path + '\' + (Split-Path $CSV -Leaf) }
    elseif($PSBoundParameters['TXT']) { $OutputFilePath = (Resolve-Path (Split-Path $TXT -Parent)).Path + '\' + (Split-Path $TXT -Leaf) }

    $ScriptTime = [Diagnostics.Stopwatch]::StartNew()
    $ErrorFileHosts,$ErrorFileVerbose = Set-ErrorFiles -ModuleName Enum-Pipe
        
    $Global:Error.Clear()

    $RemoteScriptblock = {
        $NamedPipes = [IO.Directory]::GetFiles("\\.\\pipe\\")
        $StartTime = [DateTime]::Now
        foreach ($Pipe in $NamedPipes){
            $Name = $Pipe.ToString().TrimStart("\\.\\pipe\\")
            $obj = New-Object -TypeName PSObject

            $obj | Add-Member -MemberType NoteProperty -Name TIME -Value $StartTime
            $obj | Add-Member -MemberType NoteProperty -Name NAME -Value $Name
            $obj | Add-Member -MemberType NoteProperty -Name VALUE -Value $Pipe
            Write-Output $obj
        }
    }
    
    if ($PSBoundParameters['TargetList']) {
        if ($ConfirmTargets.IsPresent) { $TargetList = Confirm-Targets $TargetList }        
        
        $ReturnedObjects = New-Object Collections.ArrayList
        $HostsRemaining = [Collections.ArrayList]$TargetList
        Write-Progress -Activity "Waiting for jobs to complete..." -Status "Hosts Remaining: $($HostsRemaining.Count)" -PercentComplete (($TargetList.Count - $HostsRemaining.Count) / $TargetList.Count * 100)

        Invoke-Command -ComputerName $TargetList -ScriptBlock $RemoteScriptBlock -SessionOption (New-PSSessionOption -NoMachineProfile) -ThrottleLimit $ThrottleLimit |
        ForEach-Object { 
            if ($HostsRemaining -contains $_.PSComputerName) { $HostsRemaining.Remove($_.PSComputerName) }
            [void]$ReturnedObjects.Add($_)
            Write-Progress -Activity "Waiting for jobs to complete..." -Status "Hosts Remaining: $($HostsRemaining.Count)" -PercentComplete (($TargetList.Count - $HostsRemaining.Count) / $TargetList.Count * 100)
        }
        Write-Progress -Activity "Waiting for jobs to complete..." -Status "Completed" -Completed
    }
    else { $ReturnedObjects = Invoke-Command -ScriptBlock $RemoteScriptBlock }

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