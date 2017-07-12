function global:pshazz_time {
	return (get-date -DisplayHint time -format T)
}

function global:pshazz_dir {
	$h = (Get-PsProvider 'FileSystem').home
	if($pwd -like $h) { return '~' }

	$dir = split-path $pwd -leaf
	if($dir -imatch '[a-z]:\\') { return '\' }
	return $dir
}

function global:pshazz_two_dir {
	$h = (Get-PsProvider 'FileSystem').home
	if($pwd -like $h) { return '~' }

	$dir = split-path $pwd -leaf
	$parent_pwd = split-path $pwd -parent
	if($dir -imatch '[a-z]:\\') { return '\' }

	if($parent_pwd) {
		if($parent_pwd -like $h)
		{
			$parent = '~'
		} else {
			$parent = split-path $parent_pwd -leaf
		}

		if( $parent -imatch '[a-z]:\\') {
			$dir = "\$dir"
		} else {
			$dir = "$parent\$dir"
		}
	}

	return $dir
}

function global:pshazz_path {
	return $pwd -replace [regex]::escape((Get-PsProvider 'FileSystem').home), "~"
}

function global:pshazz_rightarrow {
	return ([char]0xe0b0)
}

function global:pshazz_time {
	return (get-date -DisplayHint time -format T)
}

# Based on posh-git
function global:pshazz_local_or_parent_path($path) {
	$check_in = Get-Item -Force .
	if ($check_in.PSProvider.Name -ne 'FileSystem') {
		return $null
	}
	while ($check_in -ne $NULL) {
		$path_to_test = [System.IO.Path]::Combine($check_in.fullname, $path)
		if (Test-Path -LiteralPath $path_to_test) {
			return $check_in.fullname
		} else {
			$check_in = $check_in.parent
		}
	}
	return $null
}


function global:pshazz_write_prompt($prompt, $vars) {
	$vars.keys | % { set-variable $_ $vars[$_] }
	function eval($str) {
		$executionContext.invokeCommand.expandString($str)
	}

	$fg_default = $host.ui.rawui.foregroundcolor
	$bg_default = $host.ui.rawui.backgroundcolor

	# write each element of the prompt, stripping out portions
	# that evaluate to blank strings
	$prompt | % {
		$str = eval $_[2]

		# check if there is additional conditional parameter for prompt part
		if($_.Count -ge 4) {
			$cond = eval $_[3]
			$condition = ([string]::isnullorwhitespace($_[3]) -or $cond)
		} else {
			$condition = $true
		}

		# empty up the prompt part if condition fails
		if(!$condition) {
			$str = ""
		}

		if(![string]::isnullorwhitespace($str)) {
			$fg = $_[0]; $bg = $_[1]
			if(!$fg) { $fg = $fg_default }
			if(!$bg) { $bg = $bg_default }
			write-host $str -nonewline -f $fg -b $bg
		}
	}
}

if(!$global:pshazz.theme.prompt) { return } # no prompt specified, keep existing

function global:prompt {
	$saved_lastexitcode = $lastexitcode

	$global:pshazz.prompt_vars = @{
		time     = pshazz_time;
		dir      = pshazz_dir;
		two_dir  = pshazz_two_dir;
		path     = pshazz_path;
		user     = $env:username;
		hostname = $env:computername;
		rightarrow = pshazz_rightarrow;
	}

	# get plugins to populate prompt vars
	$global:pshazz.theme.plugins | % {
		$prompt_fn = "pshazz:$_`:prompt"
		if(test-path "function:\$prompt_fn") {
			& $prompt_fn
		}
	}

	pshazz_write_prompt $global:pshazz.theme.prompt $global:pshazz.prompt_vars

	$global:lastexitcode = $saved_lastexitcode
	" "
}
