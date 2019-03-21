function load_cfg {
    if (!(Test-Path $configFile)) {
        return $null
    }

    try {
        return (Get-Content $configFile -Raw | ConvertFrom-Json -ErrorAction Stop)
    } catch {
        Write-Host "ERROR loading $cfgpath`: $($_.Exception.Message)"
    }
}

function get_config($name) {
    return $cfg.$name
}

function set_config($name, $val) {
    if (!$cfg) {
        $cfg = @{ $name = $val }
    } else {
        $cfg.$name = $val
    }

    ConvertTo-Json $cfg | Set-Content $configFile -Encoding ASCII
}

$cfg = load_cfg
