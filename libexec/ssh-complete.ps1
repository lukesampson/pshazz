param($fragment) # everything after ^ssh\s*

function sshHosts($filter) {
	$config_file = "$env:USERPROFILE\.ssh\config"

	$hosts = @()
	Get-Content $config_file | where {$_ -like "Host *"} | % {
		$hosts += $_.Split(" ") | Select-Object -Skip 1 | Where {$_ -like "$filter*"}
	}

	return $hosts
}

switch -regex ($fragment) {

	# Handles ssh user@<host>
	"^(?<user>\w+)@(?<cmd>\S*)$" {
		sshHosts $matches['cmd'] | % {
			return "$($matches['user'])@$_"
		}
	}

	# Handles ssh <host>
	"^(?<cmd>\S*)$" {
		sshHosts $matches['cmd']
	}

}