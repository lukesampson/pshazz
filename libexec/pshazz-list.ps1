# Usage: pshazz list
# Summary: List available themes

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\theme.ps1"

function list_themes($dir) {
	Get-ChildItem "$dir" "*.json" |% { "  $($_.name -replace '.json$', '')" }
}

"Custom themes:"
list_themes $user_themedir

"Default themes:"
list_themes $themedir
