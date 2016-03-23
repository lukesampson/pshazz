# Usage: pshazz config [name] [val]
# Summary: Get or set pshazz config
param($name, $val)

. "$psscriptroot\..\lib\core.ps1"
. "$psscriptroot\..\lib\help.ps1"
. "$psscriptroot\..\lib\config.ps1"

if($name) {
	if($val) {
		set_config $name $val
	} else {
		get_config $name
	}
} else {
	$cfg
}


