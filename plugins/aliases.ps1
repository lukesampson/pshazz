# fixes some insane powershell aliases that interfere with real programs
# also adds some commonly used aliases
# you can specify more aliases to add and remove in the theme under aliases.rm and aliases.add
$remove = 'curl', 'wget', 'r'
$add = @{
	ll = 'ls';
}

function pshazz:aliases:init {
	$remove = @($global:pshazz.theme.aliases.rm) + $remove |? { $_ } # theme overrides

	$remove |% {
		# may need to execute the rm many times in parent scopes until really removed
		# (set-alias -option allscope copies the alias to child scopes)
		while(test-path "alias:$_") {
			Remove-Item "alias:\$_" -force
		}
	}

	$global:pshazz.theme.aliases.add.keys |? { $_ } |% {
		$add.$_ = $global:pshazz.theme.aliases.add.$_
	}

	$add.keys |% {
		$alias = $_
		$cmd = $add.$alias
		if(($alias -match '\(') -or ($cmd -match ' ')) {
			add_alias_with_params $alias $cmd # with params
		} else {
			set-alias $alias $cmd -opt allscope -scope global # without params
		}
	}
}

function add_alias_with_params($alias, $cmd) {
	# alias with extra parameters, based on
	# http://huddledmasses.org/powershell-power-user-tips-bash-style-alias-command/
	$m = $alias | sls '([^\(]+)(\([^\)]+\))' | select -first 1
	$in_param = $null

	if($m) {
		# has input parameters
		$alias, $in_param = $m.matches.groups[1..2] |% { $_.value }
	}

	$fn_body = $cmd
	if($in_param) {
		$fn_body = "param$in_param $fn_body"
	}

	$null = new-item -path function: -name "global:pshazz.alias_$alias" -options allscope -value $fn_body -force
	set-alias $alias "pshazz.alias_$alias" -opt allscope -scope global
}