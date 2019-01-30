# Usage: pshazz use <theme>
# Summary: Change the current theme
# Help: This command will configure pshazz to use the specified theme.
#
# To revert to the default theme, use 'default'. E.g.:
#     pshazz use default

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\help.ps1"
. "$psscriptroot\..\lib\config.ps1"
. "$psscriptroot\..\lib\theme.ps1"


# save theme
set_config 'theme' 'random'

# re-init
pshazz init

write-host "using random theme"