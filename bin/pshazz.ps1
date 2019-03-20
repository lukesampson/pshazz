#Requires -Version 3
param($cmd)

Set-StrictMode -Off

. "$PSScriptRoot\..\lib\core.ps1"
. "$PSScriptRoot\..\lib\config.ps1"
. "$PSScriptRoot\..\lib\commands.ps1"
. "$PSScriptRoot\..\lib\edit.ps1"
. "$PSScriptRoot\..\lib\help.ps1"
. "$PSScriptRoot\..\lib\plugin.ps1"
. "$PSScriptRoot\..\lib\theme.ps1"

$commands = commands

if (@($null, '-h', '--help', '/?') -contains $cmd) {
    exec 'help' $args
} elseif ($commands -contains $cmd) {
    exec $cmd $args
} else {
    Write-Output "pshazz: '$cmd' isn't a pshazz command. See 'pshazz help'"
    exit 1
}
