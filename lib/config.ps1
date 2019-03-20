$cfgpath = $env:PSHAZZ_CFG, "${HOME}/.pshazz" | Select-Object -first 1

function load_cfg {
    if (!(Test-Path $cfgpath)) {
        return $null
    }

    try {
        return (Get-Content $cfgpath -Raw | ConvertFrom-Json -ErrorAction Stop)
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

    ConvertTo-Json $cfg | Set-Content $cfgpath -Encoding ASCII
}

$cfg = load_cfg
