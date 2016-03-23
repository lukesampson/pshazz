#requires -v 3
param($cmd)

set-strictmode -off

. "$psscriptroot\..\lib\commands.ps1"

$commands = commands

if (@($null, '-h', '--help', '/?') -contains $cmd) { exec 'help' $args }
elseif ($commands -contains $cmd) { exec $cmd $args }
else { "pshazz: '$cmd' isn't a pshazz command. See 'pshazz help'"; exit 1 }