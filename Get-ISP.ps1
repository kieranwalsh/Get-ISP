<#
    .SYNOPSIS
    Lists the ISP for any public IP address.

    .DESCRIPTION
    Lists the ISP for any public IP address. You can chose particular IPs or your own machine.

    .PARAMETER PublicIPs
    Use this parameter to specify a list of public IP addresses to scan. If this parameter is not specified, the script will scan the public IP of the device you run it from.

    .PARAMETER ISPOnly
    Instead of outputting the results in a table form, ISPOnly will list the ISP name only. Useful if you need to supply the data to another script or RMM.

    .EXAMPLE
    C:\PS> .\Get-ISP.ps1
    Returns the public IP and the ISP of the device you are running the script from.

    .EXAMPLE
    C:\PS> .\Get-ISP.ps1 -PublicIPs 8.8.8.8,1.1.1.1
    Returns the public IP(s) and the ISP(s) of the IP Addresses supplied. For example:
    IP: 8.8.8.8     ISP: Google LLC
    IP: 1.1.1.1     ISP: APNIC and CloudFlare DNS Resolver Project

    .EXAMPLE
    C:\PS> .\Get-ISP.ps1 -ISPOnly 8.8.8.8
    Returns the ISP of the IP Address supplied without listing the IP in a table. For example:
    Google LLC

    .NOTES
    Filename: Get-ISP.ps1
    Contributors: Kieran Walsh
    Created: 2022-01-26
    Last Updated: 2022-01-26
    Version: 0.01.01
#>

[CmdletBinding()]
Param(
    [Parameter()]
    [string[]]$PublicIPs,
    [switch]$ISPOnly
)

if(-not($PublicIPs))
{
    $PublicIPs = (Invoke-WebRequest -Uri http://ifconfig.me/ip -TimeoutSec 60).Content.Trim()
}
foreach($PublicIP in $PublicIPs)
{
    $SearchURL = "https://api.iplocation.net/?ip=$PublicIP"
    $ISP = ((Invoke-WebRequest -Uri $SearchURL -UseBasicParsing).content -replace '{', '' -replace '}', '' -replace '"', '' -split ',' | Where-Object {
            $_ -match 'isp:'
        }).replace('isp:', '')

    if($ISP -match 'Private IP Address LAN')
    {
        $ISP = '* IP is not a Public IP *'
    }

    if($IspOnly)
    {
        $ISP
    }
    Else
    {
        Write-Host $('IP: {0,-17} ISP: {1}' -f $PublicIP, $ISP)
    }
}
