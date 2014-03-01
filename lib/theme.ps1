$themedir = fullpath "$psscriptroot\..\themes"
$user_themedir = "~\pshazz"

function theme($name) {
	# try userdir first
	$theme = load_theme "$user_themedir\$name.json"
	if($theme) { return $theme }

	# fall back to defaults
	load_theme "$themedir\$name.json"
}

function load_theme($path) {
	if(!(test-path $path)) { return $null }

	try {
		gc $path -raw | convertfrom-json -ea stop
	} catch {
		write-host "ERROR loading JSON for $path`: $($_.exception.message)"
	}
}

function new_theme($name) {
	if(!(test-path $user_themedir)) {
		$null = mkdir $user_themedir
	}
	cp "$themedir\default.json" "$user_themedir\$name.json"
}