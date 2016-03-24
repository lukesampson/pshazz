# Usage: pshazz rm <name>
# Summary: Remove a custom theme
param($name)

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\theme.ps1"
. "$psscriptroot\..\lib\help.ps1"

if(!$name) { "<name> is required"; my_usage; exit 1}

$path = "$user_themedir\$name.json"
if(test-path $path) {
	Remove-Item $path > $null
	"removed '$name'"
} else {
	"pshazz: '$name' custom theme not found. use 'pshazz list' to see themes."; exit 1
}
