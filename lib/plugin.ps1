$plugindir = fullpath "$PSScriptRoot\..\plugins"
$user_plugindir = $env:PSHAZZ_PLUGINS, "${HOME}/pshazz/plugins" | Select-Object -first 1

function plugin:init($name) {
    # try user plugin dir first
    $path = "$user_plugindir/$name.ps1"
    if (!(Test-Path $path)) {
        # fallback to defaults
        $path = "$plugindir/$name.ps1"
        if (!(Test-Path $path)) {
            Write-Warning "Couldn't find pshazz plugin '$name'."
            return $false
        }
    }

    . $path

    $initfn = "pshazz:$name`:init"
    if (Test-Path "function:\$initfn") {
        & $initfn
    }
}
