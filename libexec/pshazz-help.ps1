# Usage: pshazz help <command>
# Summary: Show help for a command
param($cmd)

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\commands.ps1"
. "$psscriptroot\..\lib\help.ps1"

function print_help($cmd) {
	$file = gc "$psscriptroot\pshazz-$cmd.ps1" -raw

	$usage = usage $file
	$summary = summary $file
	$help = help $file

	if($usage) { "$usage`n" }
	if($help) { $help }
}

function print_summaries {
	$commands = @{}

	command_files | % {
		$command = command_name $_
		$summary = summary (gc "$psscriptroot\$_" -raw )
		if(!($summary)) { $summary = '' }
		$commands.add("$command ", $summary) # add padding
	}

	$commands.getenumerator() | sort name | ft -hidetablehead -autosize -wrap
}

$commands = commands

if(!($cmd)) {
	"usage: pshazz <command> [<args>]

Some useful commands are:"
	print_summaries
	"type 'pshazz help <command>' to get help for a specific command"
} elseif($commands -contains $cmd) {
	print_help $cmd
} else {
	"pshazz help: no such command '$cmd'"; exit 1
}

exit 0