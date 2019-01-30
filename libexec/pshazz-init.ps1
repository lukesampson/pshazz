# Usage: pshazz init
# Summary: Initialize pshazz
# Help: Usually this is called from your PS profile.
#
# When initializing, pshazz will use the theme configured in $env:USERPROFILE/.pshazz
# or otherwise revert to the default theme.
. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\help.ps1"
. "$psscriptroot\..\lib\theme.ps1"
. "$psscriptroot\..\lib\plugin.ps1"
. "$psscriptroot\..\lib\config.ps1"

function init($theme_name) {
	$theme = theme $theme_name

	if(!$theme) {
		"pshazz: error: couldn't load theme '$theme_name' in $themedir"

		# try reverting to default theme
		if($theme_name -ne 'default') {
			$theme_name = 'default'
			$theme = theme $theme_name
		}
		else { exit 1 } # already tried loading default theme, abort
	}

	$global:pshazz = @{ }
	$pshazz.theme_name = $theme_name
	$pshazz.theme = $theme
	$pshazz.completions = @{ }

	@($theme.plugins) |? { $_ } |% {
		plugin:init $_
	}
}

$theme = get_config 'theme'
if(!$theme) { $theme = 'default' }
init $theme

. "$psscriptroot\..\lib\prompt.ps1"
. "$psscriptroot\..\lib\completion.ps1"