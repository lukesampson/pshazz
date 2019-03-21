# The refresh script is for development only
$src = Resolve-Path "$PSScriptRoot\.."
$dest = Resolve-Path "$(Split-Path (scoop which pshazz))\.."

# make sure not running from the installed directory
if ("$src" -eq "$dest") {
    Write-Output "The refresh script is for development only."
    return
}

Write-Host -NoNewline 'Copying files.'
robocopy $src $dest /mir /njh /njs /nfl /ndl /xd .git /xf .DS_Store manifest.json install.json > $null
Write-Host ' Done.' -f DarkGreen

Write-Host 'Reloading pshazz.'
pshazz init
