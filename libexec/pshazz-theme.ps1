# Usage: pshazz theme [name]
# Summary: Show or change the current theme
# Help: This command will configure pshazz to use the specified theme.
#
# Without a [name]
#
# To revert to the default theme, use 'default'. E.g.:
#     pshazz use default
param($name)

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\help.ps1"
. "$psscriptroot\..\lib\config.ps1"
. "$psscriptroot\..\lib\theme.ps1"

if(!$name) {
	$global:pshazz.theme_name
	exit 1
}

# make sure valid theme
$theme = theme $name
if(!$theme) { "pshazz: couldn't find the theme named '$name'"; exit 1 }

# save theme
cfg_set_theme $name

# re-init
pshazz init

write-host "will use '$name' theme"
write-host "please start a new session to see all changes (e.g. type 'powershell')"