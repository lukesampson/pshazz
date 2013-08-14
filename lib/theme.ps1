$themedir = fullpath "$psscriptroot\..\themes"

function theme($name) {
	$path = "$themedir\$name.json"
	if(!(test-path $path)) { return $null }

	try {
		gc $path -raw | convertfrom-json -ea stop
	} catch {
		write-host "ERROR loading JSON for $path`: $($_.exception.message)"
	}
}