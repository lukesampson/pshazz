function fullpath($path) {
	$executionContext.sessionState.path.getUnresolvedProviderPathFromPSPath($path)
}

function hashtable($obj) {
	$h = @{ }
	$obj.psobject.properties | % {
		$h[$_.name] = hashtable_val $_.value;
	}
	return $h
}

function hashtable_val($obj) {
	if($obj -is [object[]]) {
		$arr = @()
		$obj | % {
			$val = hashtable_val $_
			if($val -is [array]) {
				$arr += ,@($val)
			} else {
				$arr += $val
			}
		}
		return $arr
	}
	if($obj.gettype().name -eq 'pscustomobject') { # -is is unreliable
		return hashtable($obj)
	}
	return $obj # assume primitive
}