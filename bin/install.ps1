if(!(test-path $profile)) {
	$profile_dir = split-path $profile
	if(!(test-path $profile_dir)) { mkdir $profile_dir > $null }
	'' > $profile
}

$old_init = "try { `$null = gcm pshazz -ea stop; pshazz init 'default' } catch { }"
$new_init = "try { `$null = gcm pshazz -ea stop; pshazz init } catch { }"

$text = gc $profile
if(($text | sls 'pshazz') -eq $null) {
	write-host 'adding pshazz to your powershell profile'

	# read and write whole profile to avoid problems with line endings and encodings
	$new_profile = @($text) + "try { `$null = gcm pshazz -ea stop; pshazz init 'default' } catch { }"
	$new_profile > $profile
} elseif($text -contains $old_init) {
	write-host 'updating pshazz init in your powershell profile'
	$new_profile = $text -replace [regex]::escape($old_init), $new_init
	$new_profile > $profile
} else {
	write-host 'it looks like pshazz is already in your powershell profile, skipping'
}

""
"           _                   _ "
" _ __  ___| |__   __ _ _______| |"
"| '_ \/ __| '_ \ / _`` |_  /_  / |"
"| |_) \__ \ | | | (_| |/ / / /|_|"
"| .__/|___/_| |_|\__,_/___/___(_)"
"|_|"
""

& "$psscriptroot\pshazz" init
