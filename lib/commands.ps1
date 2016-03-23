function command_files {
	gci "$psscriptroot\..\libexec" | where { $_.name -match 'pshazz-.*?\.ps1$' }
}

function commands {
	command_files | % { command_name $_ }
}

function command_name($filename) {
	$filename.name | sls 'pshazz-(.*?)\.ps1$' | % { $_.matches[0].groups[1].value }
}

function exec($cmd, $arguments) {
	& "$psscriptroot\..\libexec\pshazz-$cmd.ps1" @arguments
}