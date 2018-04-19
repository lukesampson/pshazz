$plugindir = fullpath "$psscriptroot\..\plugins"
$user_plugindir = $env:PSHAZZ_PLUGINS, "$env:USERPROFILE\pshazz\plugins" | Select-Object -first 1

function plugin:init($name) {
    # try user plugin dir first
    $path = "$user_plugindir\$name.ps1"
    if(!(test-path $path)) {
        # fallback to defaults
        $path = "$plugindir\$name.ps1"
        if(!(test-path $path)) {
            Write-Warning "Couldn't find pshazz plugin '$name'."; return
        }
    }

    . $path

    $initfn = "pshazz:$name`:init"
    if(test-path "function:\$initfn") {
        & $initfn
    }
}