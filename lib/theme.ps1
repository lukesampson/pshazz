function theme($name) {
    $path = find_path $name

    if ([bool]$path) {
        $theme = load_theme $path
        if ($theme) {
            return $theme
        }
    }
}

function find_path($name) {
    # try user dir first
    $path = "$userThemeDir\$name.json"
    if (Test-Path $path) {
        return $path
    }

    # fallback to builtin dir
    $path = "$themeDir\$name.json"
    if (Test-Path $path) {
        return $path
    }
}

function load_theme($path) {
    try {
        return (Get-Content $path -Raw | ConvertFrom-Json -ErrorAction Stop)
    } catch {
        Write-Host "ERROR loading JSON for '$path'`:"
        Write-Host "$($_.Exception.Message)" -f DarkRed
    }
}

function new_theme($name) {
    if (!(Test-Path $userThemeDir)) {
        New-Item -Path $userThemeDir -ItemType Directory | Out-Null
    }
    Copy-Item "$themeDir\default.json" "$userThemeDir\$name.json"
}
