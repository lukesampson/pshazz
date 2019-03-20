# Usage: pshazz rm <name>
# Summary: Remove a custom theme
param($name)

. "$PSScriptRoot\..\lib\core.ps1"
. "$PSScriptRoot\..\lib\theme.ps1"
. "$PSScriptRoot\..\lib\help.ps1"

if (!$name) {
    my_usage
    exit 1
}

$path = "$user_themedir\$name.json"
if (Test-Path $path) {
    Remove-Item $path -Force | Out-Null
    Write-Output "Removed custom theme '$name'."
} else {
    Write-Output "pshazz: '$name' custom theme not found. use 'pshazz list' to see themes."
    exit 1
}
