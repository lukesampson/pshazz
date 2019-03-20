#Requires -Version 3
param($cmd)

Set-StrictMode -Off

. "$PSScriptRoot\..\lib\commands.ps1"

$commands = commands

if (@($null, '-h', '--help', '/?') -contains $cmd) {
    exec 'help' $args
} elseif ($commands -contains $cmd) {
    exec $cmd $args
} else {
    Write-Output "pshazz: '$cmd' isn't a pshazz command. See 'pshazz help'"
    exit 1
}
