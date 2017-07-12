$cfgpath = $env:PSHAZZ_CFG, "$env:USERPROFILE/.pshazz" | select -first 1

function to_hashtable($obj) {
	$ht = @{}
	$obj | gm |? { $_.membertype -eq 'noteproperty'} |% {
		$name = $_.name
		$ht[$name] = $obj.$name
	}
	return $ht
}

function load_cfg {
	if(!(test-path $cfgpath)) { return $null }

	try {
		hashtable (gc $cfgpath -raw | convertfrom-json -ea stop)
	} catch {
		write-host "ERROR loading $cfgpath`: $($_.exception.message)"
	}
}

function get_config($name) {
	return $cfg.$name
}

function set_config($name, $val) {
	if(!$cfg) {
		$cfg = @{ $name = $val }
	} else {
		$cfg.$name = $val
	}

	convertto-json $cfg | out-file $cfgpath -encoding utf8
}

$cfg = load_cfg