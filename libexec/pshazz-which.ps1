# Usage: pshazz which <name>
# Summary: Print the theme's path

param($name)

. "$PSScriptRoot\..\lib\core.ps1"
. "$PSScriptRoot\..\lib\theme.ps1"
. "$PSScriptRoot\..\lib\help.ps1"

if (!$name) {
    my_usage
    exit 1
}

find_path $name
