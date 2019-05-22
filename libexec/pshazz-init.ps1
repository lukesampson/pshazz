# Usage: pshazz init
# Summary: Initialize pshazz
# Help: Usually this is called from your PS profile.
#
# When initializing, pshazz will use the theme configured in $env:USERPROFILE/.pshazz
# or otherwise revert to the default theme.

function init($theme_name) {
    $theme = theme $theme_name

    if (!$theme) {
        "pshazz: error: couldn't load theme '$theme_name'."

        # try reverting to default theme
        if ($theme_name -ne 'default') {
            $theme_name = 'default'
            $theme = theme $theme_name
        } else {
            # already tried loading default theme, abort
            exit 1
        }
    }

    $global:pshazz = @{}
    $pshazz.theme_name = $theme_name
    $pshazz.theme = $theme
    $pshazz.completions = @{}

    @($theme.plugins) | Where-Object { $_ } | ForEach-Object {
        plugin:init $_
    }
}

$theme = get_config 'theme'

# get a random theme
if ($theme -eq 'random') {
    $themes = @()

    Get-ChildItem "$themeDir" "*.json" | ForEach-Object {
        $themes += $($_.Name -replace '.json$', '')
    }

    if (Test-Path $userThemeDir) {
        Get-ChildItem "$userThemeDir" "*.json" | ForEach-Object {
            $themes += $($_.Name -replace '.json$', '')
        }
    }

    $theme = $themes[(Get-Random -Maximum ($themes.Count) -SetSeed (Get-Random -Maximum (Get-Random)))]
    "pshazz: loaded random theme $theme"
}

if (!$theme) {
    $theme = 'default'
}

init $theme

. "$PSScriptRoot\..\lib\prompt.ps1"
. "$PSScriptRoot\..\lib\completion.ps1"
