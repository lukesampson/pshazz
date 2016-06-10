# Usage: pshazz list
# Summary: List available themes

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\theme.ps1"

function list_themes($dir) {
	gci "$dir" "*.json" |% { "  $($_.name -replace '.json$', '')" }
}

"Default themes:"
list_themes $themedir

"Custom themes:"
if(Test-Path $user_themedir) {
	list_themes $user_themedir
} else {
    ""
}
