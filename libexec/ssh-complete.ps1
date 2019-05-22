# everything after ^ssh\s*
param($fragment)

function Get-SshHost($filter) {
    $sshConfig = "$env:USERPROFILE\.ssh\config"

    $hosts = @()
    Get-Content $sshConfig | Where-Object { $_ -like "Host *" } | ForEach-Object {
        $hosts += $_.Split(" ") | Select-Object -Skip 1 | Where-Object {
            $_ -like "$filter*"
        }
    }

    return $hosts
}

switch -Regex ($fragment) {
    # Handles ssh user@<host>
    "^(?<user>\w+)@(?<cmd>\S*)$" {
        Get-SshHost $matches['cmd'] | ForEach-Object {
            return "$($matches['user'])@$_"
        }
    }

    # Handles ssh <host>
    "^(?<cmd>\S*)$" {
        Get-SshHost $matches['cmd']
    }
}
