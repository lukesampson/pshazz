# Usage: pshazz list
# Summary: List available themes

function list_themes($dir) {
    $themes = @()

    Get-ChildItem "$dir" "*.json" | ForEach-Object {
        $themes += [System.IO.Path]::GetFileNameWithoutExtension($_.Name)
    }

    Write-Output ($themes | Format-Wide { $_ } -AutoSize -Force | Out-String).Trim()
}

Write-Host "Builtin themes:" -f DarkGreen
list_themes $themeDir

if (Test-Path $userThemeDir) {
    Write-Host "Custom themes:" -f DarkGreen
    list_themes $userThemeDir
}
