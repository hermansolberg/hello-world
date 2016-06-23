param (
    [String]$Uri,
    [String]$Output = $PSScriptRoot + "\WebRequestMonitor.csv",
    [Int32]$WaitTime = 60
)

$OutPutFile = New-Object -TypeName System.IO.FileInfo -ArgumentList $Output

if($OutPutFile.Exists -eq $false)
{
    if($OutPutFile.Directory.Exists -eq $false)
    {
        $OutPutFile.Directory.Create()
    }
     
     $File = $OutPutFile.Create()
     $File.Close()
}

While($true)
{
    $StartTime = [DateTime]::Now
    $Response = Invoke-WebRequest -Uri $Uri -UseDefaultCredentials
    if($Response.StatusCode -eq 200)
    {
        $Object = New-Object -TypeName PSObject
        Add-Member -InputObject $Object -MemberType NoteProperty -Name Date -Value $StartTime.ToShortDateString()
        Add-Member -InputObject $Object -MemberType NoteProperty -Name Time -Value $StartTime.ToLongTimeString()
        Add-Member -InputObject $Object -MemberType NoteProperty -Name SPRequestGuid -Value $Response.Headers.SPRequestGuid
        Add-Member -InputObject $Object -MemberType NoteProperty -Name SPRequestDuration -Value $Response.Headers.SPRequestDuration
        Add-Member -InputObject $Object -MemberType NoteProperty -Name SPClientServiceRequestDuration -Value $Response.Headers.SPClientServiceRequestDuration
        $Object | Export-Csv -LiteralPath $OutPutFile.FullName -Append -NoTypeInformation
        $Object | FT -AutoSize
    }
    else
    {
        Write-Error "WebRequest failed"
    }

    Start-Sleep -Seconds $WaitTime
}