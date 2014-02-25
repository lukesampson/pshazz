$cfgpath = "~/.pshazz"

function load_cfg {
	if(!(test-path $cfgpath)) { return $null }

	try {
		gc $cfgpath -raw | convertfrom-json -ea stop
	} catch {
		write-host "ERROR loading $cfgpath`: $($_.exception.message)"
	}
}

$cfg = load_cfg

function cfg_theme {
	if(!$cfg) { return $null }
	return $cfg.theme
}

function cfg_set_theme($theme) {
	if(!$cfg) {
		$cfg = new-object psobject @{ theme = $theme }
	} else {
		$cfg.theme = $theme
	}

	convertto-json $cfg | out-file $cfgpath -encoding utf8
}