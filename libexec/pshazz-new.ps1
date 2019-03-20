# Usage: pshazz new <name>
# Summary: Create a new theme
# Help: Creates a new theme and opens it in an editor.
#
# The new theme will use the default theme as a template.
param($name)

if (!$name) {
    my_usage
    exit 1
}

$new_path = "$user_themedir\$name.json"

if (Test-Path $new_path) {
    Write-Output "You already have a theme named $name. Type 'pshazz edit $name' to edit it."
    exit 1
}

new_theme $name

$editor = editor

if (!$editor) {
    Write-Output "Couldn't find a text editor!"
    exit 1
}

& $editor (Resolve-Path $new_path)

Write-Output "Type 'pshazz use $name' when you're ready to try your theme."
