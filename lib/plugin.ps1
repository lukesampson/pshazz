function plugin:init($name) {
    # try user plugin dir first
    $path = "$userPluginDir\$name.ps1"
    if (!(Test-Path $path)) {
        # fallback to defaults
        $path = "$pluginDir\$name.ps1"
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
