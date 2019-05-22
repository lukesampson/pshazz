# Usage: pshazz rm <name>
# Summary: Remove a custom theme
param($name)

if (!$name) {
    my_usage
    exit 1
}

$path = "$userThemeDir\$name.json"
if (Test-Path $path) {
    Remove-Item $path -Force | Out-Null
    Write-Output "Removed custom theme '$name'."
} else {
    Write-Output "pshazz: '$name' custom theme not found. use 'pshazz list' to see themes."
    exit 1
}
