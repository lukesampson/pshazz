if (!(Test-Path $PROFILE)) {
    $profileDir = Split-Path $PROFILE

    if (!(Test-Path $profileDir)) {
        New-Item -Path $profileDir -ItemType Directory | Out-Null
    }

    '' > $PROFILE
}

$old_init = "try { `$null = gcm pshazz -ea stop; pshazz init 'default' } catch { }"
$new_init = "try { `$null = gcm pshazz -ea stop; pshazz init } catch { }"

$text = Get-Content $PROFILE

if ($null -eq ($text | Select-String 'pshazz')) {
    Write-Output 'Adding pshazz to your powershell profile.'

    # read and write whole profile to avoid problems with line endings and encodings
    $new_profile = @($text) + "try { `$null = gcm pshazz -ea stop; pshazz init 'default' } catch { }"
    $new_profile > $PROFILE
} elseif ($text -contains $old_init) {
    Write-Output 'Updating pshazz init in your powershell profile.'
    $new_profile = $text -replace [Regex]::Escape($old_init), $new_init
    $new_profile > $PROFILE
} else {
    Write-Output 'It looks like pshazz is already in your powershell profile, skipping.'
}

""
"           _                   _ "
" _ __  ___| |__   __ _ _______| |"
"| '_ \/ __| '_ \ / _`` |_  /_  / |"
"| |_) \__ \ | | | (_| |/ / / /|_|"
"| .__/|___/_| |_|\__,_/___/___(_)"
"|_|"
""

& "$PSScriptRoot\pshazz" init

Write-Host "Your PowerShell is now powered by pshazz!" -f DarkGreen
