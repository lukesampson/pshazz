# Usage: pshazz edit <name>
# Summary: Edit a theme

param($name)

if (!$name) {
    my_usage
    exit 1
}

$path = "$user_themedir\$name.json"

if (!(Test-Path $path)) {
    if (!(Test-Path $user_themedir)) {
        New-Item -Path $user_themedir -ItemType Directory | Out-Null
    }

    # see if it's a default theme, and copy it if it is
    if (Test-Path "$themedir\$name.json") {
        Copy-Item "$themedir\$name.json" $path
    } else {
        Write-Output "pshazz: couldn't find a theme named '$name'. Type 'pshazz list' to see themes."
        exit 1
    }
}

$editor = editor
if (!$editor) {
    Write-Output "Couldn't find a text editor!"
    exit 1
}

& $editor (resolve-path $path)

Write-Output "Type 'pshazz use $name' when you're ready to try your theme."
