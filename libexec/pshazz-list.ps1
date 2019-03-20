# Usage: pshazz list
# Summary: List available themes

. "$PSScriptRoot\..\lib\core.ps1"
. "$PSScriptRoot\..\lib\theme.ps1"

function list_themes($dir) {
    $themes = @()

    Get-ChildItem "$dir" "*.json" | ForEach-Object {
        $themes += [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    }

    Write-Output ($themes | Format-Wide { $_ } -AutoSize -Force | Out-String).Trim()
}

Write-Host "Builtin themes:" -f DarkGreen
list_themes $themedir

if (Test-Path $user_themedir) {
    Write-Host "Custom themes:" -f DarkGreen
    list_themes $user_themedir
}
