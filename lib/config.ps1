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
    # Ensure configFile exists
    if (!(Test-Path $configFile)) {
        New-Item $configFile -Force -ErrorAction Ignore | Out-Null
    }

    if (!$cfg) {
        $cfg = @{ $name = $val }
    } else {
        if ($null -eq $cfg.$name) {
            $cfg | Add-Member -MemberType NoteProperty -Name $name -Value $val
        } else {
            $cfg.$name = $val
        }
    }

    ConvertTo-Json $cfg | Set-Content $configFile -Encoding ASCII
}

$cfg = load_cfg
