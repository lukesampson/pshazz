# Usage: pshazz edit <name>
# Summary: Edit a theme

param($name)

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\theme.ps1"
. "$psscriptroot\..\lib\edit.ps1"
. "$psscriptroot\..\lib\help.ps1"
. "$psscriptroot\..\lib\config.ps1"

if(!$name) { "<name> is required"; my_usage; exit 1 }

$path = "$user_themedir\$name.json"

if(!(test-path $path)) {
    if(!(test-path $user_themedir)) {
        $null = mkdir $user_themedir
    }
	# see if it's a default theme, and copy it if it is
	if(test-path "$themedir\$name.json") {
		cp "$themedir\$name.json" $path
	} else {
		"pshazz: couldn't find a theme named '$name'. use 'pshazz list' to see themes"; exit 1;
	}
}

$editor = editor
if(!$editor) {
	"couldn't find a text editor!"; exit 1
}

& $editor (resolve-path $path)

"type 'pshazz use $name' when you're ready to try your theme"