if(!(test-path $profile)) {
	$profile_dir = split-path $profile
	if(!(test-path $profile_dir)) { mkdir $profile_dir > $null } 
	'' > $profile
}
if((gc $profile | sls 'pshazz') -eq $null) {
	write-host 'adding pshazz to your powershell profile'
	$new_profile = (gc $profile -raw) + "`r`ntry { `$null = gcm pshazz -ea stop; pshazz init 'default' } catch { }`r`n"
    $new_profile > $profile
} else {
	write-host 'it looks like pshazz is already in your powershell profile, skipping'
}

& "$psscriptroot\pshazz" init 'default'
