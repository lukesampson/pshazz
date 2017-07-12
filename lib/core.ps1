function fullpath($path) {
	$executionContext.sessionState.path.getUnresolvedProviderPathFromPSPath($path)
}

function friendly_path($path) {
	$h = (Get-PsProvider 'FileSystem').home
	if(!$h.endswith('\')) { $h += '\' }
	return "$path" -replace ([regex]::escape($h)), "~\"
}

function hashtable($obj) {
	$h = @{ }
	$obj.psobject.properties | % {
		$h[$_.name] = hashtable_val $_.value
	}
	return $h
}

function hashtable_val($obj) {
	if($obj -is [array]) {
		$arr = @()
		$obj | % {
			$val = hashtable_val $_
			if($val -is [array]) {
				$arr += ,@($val)
			} else {
				$arr += $val
			}
		}
		return ,$arr
	}
	if($obj -and $obj.gettype().name -eq 'pscustomobject') { # -is is unreliable
		return hashtable $obj
	}
	return $obj # assume primitive
}

# checks if the current theme's prompt will use a variable
function prompt_uses($varname) {
	foreach($item in $global:pshazz.theme.prompt) {
		if($item[2] -match "\`$$varname\b") { return $true }
	}
	return $false
}