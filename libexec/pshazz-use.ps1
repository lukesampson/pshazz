# Usage: pshazz use <theme>
# Summary: Change the current theme
# Help: This command will configure pshazz to use the specified theme.
#
# To revert to the default theme, use 'default'. E.g.:
#     pshazz use default
param($name)

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\help.ps1"
. "$psscriptroot\..\lib\config.ps1"
. "$psscriptroot\..\lib\theme.ps1"

if(!$name) {
	"using $($global:pshazz.theme_name)"
	exit 1
}

# make sure valid theme
$theme = theme $name
if(!$theme) { "pshazz: couldn't find the theme named '$name'"; exit 1 }

# save theme
set_config 'theme' $name

# re-init
pshazz init

write-host "using '$name' theme"