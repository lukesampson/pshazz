function fullpath($path) {
    $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($path)
}

# checks if the current theme's prompt will use a variable
function prompt_uses($varname) {
    foreach($item in $global:pshazz.theme.prompt) {
        if ($item[2] -match "\`$$varname\b") {
            return $true
        }
    }
    return $false
}

# Pshazz Env
$configHome = $env:XDG_CONFIG_HOME, "$env:USERPROFILE\.config" | Select-Object -First 1
$configFile = "$configHome\pshazz\config.json"
$pluginDir = fullpath "$PSScriptRoot\..\plugins"
$userPluginDir = "$configHome\pshazz\plugins"
$themeDir = fullpath "$PSScriptRoot\..\themes"
$userThemeDir = "$configHome\pshazz\themes"

# Migration

if ((Test-Path "$env:USERPROFILE\.pshazz") -and !(Test-Path $configFile)) {
    New-Item -ItemType Directory (Split-Path -Path $configFile) -ErrorAction Ignore | Out-Null
    Move-Item "$env:USERPROFILE\.pshazz" $configFile
    Write-Host "WARNING: pshazz configuration has been migrated from '~/.pshazz' to '$configFile'" -f DarkYellow
}

if ((Test-Path "$env:USERPROFILE\pshazz\plugins") -and !(Test-Path $userPluginDir)) {
    Move-Item "$env:USERPROFILE\pshazz\plugins" "$userPluginDir\..\" -Force
    Write-Host "WARNING: pshazz user plugins have been migrated from '~/pshazz/plugins' to '$userPluginDir'" -f DarkYellow
}

if ((Test-Path "$env:USERPROFILE\pshazz") -and !(Test-Path $userThemeDir)) {
    New-Item -Path $userThemeDir -ItemType Directory -ErrorAction Ignore | Out-Null
    Move-Item "$env:USERPROFILE\pshazz\*.json" "$userThemeDir" -Force
    Write-Host "WARNING: pshazz user themes have been migrated from '~/pshazz/' to '$userThemeDir'" -f DarkYellow
    Remove-Item -Recurse -Force "$env:USERPROFILE\pshazz"
}
