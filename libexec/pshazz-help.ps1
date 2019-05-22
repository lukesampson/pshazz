# Usage: pshazz help <command>
# Summary: Show help for a command
param($cmd)

function print_help($cmd) {
    $file = Get-Content "$PSScriptRoot\pshazz-$cmd.ps1" -Raw

    $usage = usage $file
    $summary = summary $file
    $help = help $file

    if ($usage) { "$usage" }
    if ($help) { "`n$help" }
}

function print_summaries {
    $summaries = @{}

    command_files | ForEach-Object {
        $command = command_name $_
        $summary = summary (Get-Content $_.FullName -Raw )
        if (!($summary)) { $summary = '' }
        $summaries.Add("$command ", $summary) # add padding
    }

    ($summaries.GetEnumerator() | Sort-Object name | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String).TrimEnd()
}

$commands = commands

if (!($cmd)) {
    "Usage: pshazz <command> [<args>]

Some useful commands are:"
    print_summaries
    "`nType 'pshazz help <command>' to get help for a specific command."
} elseif ($commands -contains $cmd) {
    print_help $cmd
} else {
    "pshazz help: no such command '$cmd'"; exit 1
}

exit 0
