# Usage: pshazz new <name>
# Summary: Create a new theme
# Help: Creates a new theme and opens it in an editor.
#
# The new theme will use the default theme as a template.
param($name)

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\theme.ps1"
. "$psscriptroot\..\lib\edit.ps1"
. "$psscriptroot\..\lib\help.ps1"
. "$psscriptroot\..\lib\config.ps1"

if(!$name) { "<name> is required"; my_usage; exit 1 }

$new_path = "$user_themedir\$name.json"

if(test-path $new_path) {
	"you already have a theme named $name. use 'pshazz edit $name' to edit it";
	exit 1
}

new_theme $name

$editor = editor

if(!$editor) {
	"couldn't find a text editor!"; exit 1
}

& $editor (resolve-path $new_path)

"type 'pshazz use $name' when you're ready to try your theme"