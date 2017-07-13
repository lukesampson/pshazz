$themedir = friendly_path (fullpath "$psscriptroot\..\themes")
$user_themedir = $env:PSHAZZ_THEMES, "$env:USERPROFILE/pshazz" | select -first 1

function theme($name) {
	$path = find_path $name
	$theme = load_theme $path
	if($theme) {
		hashtable $theme
	}
}

function find_path($name) {
	# try user dir first
	$path = "$user_themedir\$name.json"
	if(test-path $path) { return $path }

	# fall back to defaults
	$path = "$themedir\$name.json"
	if(test-path $path) { return $path }
}

function load_theme($path) {
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