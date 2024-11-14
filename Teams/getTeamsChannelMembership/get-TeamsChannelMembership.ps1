#Requires -Modules MicrosoftTeamsPowerShell
<#
.Synopsis
Gets a list of all members in an MSTeams Team

.Description
Gets all members of a given MSTeams Team, this requires permissions to access the information (for instance Teams Admin), output will be the user, their name and their role in the Team.

.Notes
License
This program/script is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
This program/script is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
You should have received a copy of the GNU General Public License along with this program/script. If not, see https://www.gnu.org/licenses/.

.Notes
Requires the following:
    MicrosoftTeamsPowerShell
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
$connAttempt = 1
clear-variable testCon -ErrorAction SilentlyContinue
try { $testCon = Get-CSTenant -ErrorAction Stop }
catch {
    do {
        if ($connAttempt -gt $maxConnectionAttempts) {
            write-error "Error occured connecting to MS Teams"
            Exit 2
        }
        Connect-MicrosoftTeams
        $testCon = Get-CSTenant -ErrorAction SilentlyContinue
        $connAttempt++
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