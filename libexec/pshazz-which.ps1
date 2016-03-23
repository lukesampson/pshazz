# Usage: pshazz which <name>
# Summary: Print the theme's path

param($name)

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\theme.ps1"
. "$psscriptroot\..\lib\help.ps1"

if(!$name) { "<name> is required"; my_usage; exit 1}

find_path $name