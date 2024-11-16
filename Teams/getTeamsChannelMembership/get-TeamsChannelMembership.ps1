#Requires -Modules MicrosoftTeamsPowerShell

<#
    .SYNOPSIS

    Gets a list of all members in an MSTeams Team

    .DESCRIPTION

    Gets all members of a given MSTeams Team, this requires permissions to access the information (for instance Teams Admin), output will be the user, their name and their role in the Team.

    .NOTES

    License
    This program/script is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
    This program/script is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
    You should have received a copy of the GNU General Public License along with this program/script. If not, see https://www.gnu.org/licenses/.

    Disclaimer
    This code is provided under good faith, in no event will I be liable for any loss or damage including without limitation, indirect or consequential loss or damage, or any loss or damage whatsoever arising from loss of data or profits arising out of, or in connection with, the use of this code.
    Use at your own risk, always check code obtained from the internet before running it.

    Requires the following:
        MicrosoftTeamsPowerShell

    .PARAMETER teamDisplayName

    Manditory parameter, name of the team to search for and return the users from.  This should be the exact name of the team, wild cards are not accepted.

    .PARAMETER maxConnectionAttempts

    Optional parameter, default value is set to 5.  This is the amount of retries to connect to azure before exiting with failure. 

    .EXAMPLE

    get-TeamsChannelMembership.ps1 -teamDisplayName "Employee Network 1" -maxConnectionAttempts 5
#>

[CmdletBinding()]
Param(
    [Parameter(
        Mandatory=$true,
        Position=0
    )]
    [string]$teamDisplayName,
    [Parameter(
        Mandatory=$false,
        Position=1
    )]
    [int16]$maxConnectionAttempts = 5
)

# Test that we can connect to MS Teams
$connAttempt = 0
clear-variable testCon -ErrorAction SilentlyContinue
try { $testCon = Get-CSTenant -ErrorAction Stop }
catch {
    do {
        $connAttempt++
        if ($connAttempt -gt $maxConnectionAttempts) {
            write-error "Error occured connecting to MS Teams"
            Exit 2
        }
        Connect-MicrosoftTeams
        $testCon = Get-CSTenant -ErrorAction SilentlyContinue
    } until ($testCon)
}

# Get Team and Members of the Team
$teamObj = Get-Team -DisplayName $teamDisplayName
if ($teamObj) {
    if ($teamObj -is [Array]) {
        foreach ($team in $teamObj) {
            Get-TeamUser -GroupID $team.groupID | Select-Object User, Name, Role 
        }
    }
    else {
        Get-TeamUser -GroupID $teamObj.groupID | Select-Object User, Name, Role 
    }
    
}
else {
    Write-Error "$teamDisplayName not found, please ensure it is exact"
    Exit 3
}