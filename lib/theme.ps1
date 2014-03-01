$themedir = fullpath "$psscriptroot\..\themes"
$user_themedir = "~\pshazz"

function theme($name) {
	$path = "$themedir\$name.json"
	if(!(test-path $path)) { return $null }

	try {
		gc $path -raw | convertfrom-json -ea stop
	} catch {
		write-host "ERROR loading JSON for $path`: $($_.exception.message)"
	}
}

function user_theme_path($name) { "$user_themedir\$name.json" }

function new_theme($name) {
	if(!(test-path $user_themedir)) {
		$null = mkdir $user_themedir
	}
	cp "$themedir\default.json" (user_theme_path $name )
}