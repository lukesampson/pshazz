# tab completion
function global:tabExpansion($line, $lastWord) {
	$expression = [regex]::split($line, '[|;]')[-1].trimstart()

	foreach($cmd in $global:pshazz.completions.keys) {
		if($expression -match "^$cmd\s+(?<fragment>.*)") {
			return & $global:pshazz.completions[$cmd] $matches['fragment']
		}
	}
}
